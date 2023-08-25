module Nats.Internal.SocketState exposing
    ( SocketState
    , addRequest
    , addSubscription
    , finalizeSubscriptions
    , handleTimeouts
    , init
    , receive
    , setStatus
    )

import Dict exposing (Dict)
import Nats.Errors exposing (Timeout)
import Nats.Internal.Types as Types
import Nats.Nuid as Nuid exposing (Nuid)
import Nats.Protocol as Protocol
import Nats.Socket as Socket
import Time


init : Types.Socket msg -> SocketState msg
init (Types.Socket socket) =
    { socket = socket
    , status = Socket.Undefined
    , partialOperation = Nothing
    , serverInfo = Nothing
    , lastSubID = 0
    , activeSubscriptions = []
    , nextSubscriptions = Dict.empty
    }


type SubType msg
    = Closed
    | Sub
    | Req
        { deadline : Int
        , onTimeout : Time.Posix -> msg
        , onMessage : Protocol.Message -> ( Maybe Protocol.Message, Bool )
        }


type alias Subscription msg =
    { id : String
    , subject : String
    , group : String
    , handlers : List (Protocol.Message -> msg)
    , subType : SubType msg
    }


isRequest : Subscription msg -> Bool
isRequest sub =
    case sub.subType of
        Req _ ->
            True

        _ ->
            False


type alias SocketState msg =
    { socket : Types.SocketProps msg
    , status : Socket.Status
    , partialOperation : Maybe Protocol.PartialOperation
    , serverInfo : Maybe Protocol.ServerInfo
    , lastSubID : Int
    , activeSubscriptions : List (Subscription msg)
    , nextSubscriptions : Dict ( String, String ) (Subscription msg)

    -- , lastSeen : Maybe Time
    }


setStatus : Socket.Status -> SocketState msg -> SocketState msg
setStatus status state =
    { state
        | status = status
    }


getSubscriptionByID : String -> SocketState msg -> Maybe (Subscription msg)
getSubscriptionByID id state =
    state.activeSubscriptions
        |> List.filter (.id >> (==) id)
        |> List.head


getSubscriptionBySubjectGroup : ( String, String ) -> SocketState msg -> Maybe (Subscription msg)
getSubscriptionBySubjectGroup ( subject, group ) state =
    state.activeSubscriptions
        |> List.filter (\sub -> ( sub.subject, sub.group ) == ( subject, group ))
        |> List.head


nextID : SocketState msg -> Int
nextID state =
    state.lastSubID + 1


addSubscription : String -> String -> (Protocol.Message -> msg) -> SocketState msg -> SocketState msg
addSubscription =
    addSubscriptionHelper Sub


addSubscriptionHelper : SubType msg -> String -> String -> (Protocol.Message -> msg) -> SocketState msg -> SocketState msg
addSubscriptionHelper subType subject group onMessage state =
    case Dict.get ( subject, group ) state.nextSubscriptions of
        Just sub ->
            { state
                | nextSubscriptions =
                    state.nextSubscriptions
                        |> Dict.insert ( subject, group )
                            { sub
                                | handlers = onMessage :: sub.handlers
                            }
            }

        Nothing ->
            let
                ( subID, lastSubID ) =
                    case getSubscriptionBySubjectGroup ( subject, group ) state of
                        Just sub ->
                            ( sub.id, state.lastSubID )

                        Nothing ->
                            ( String.fromInt <| nextID state, nextID state )
            in
            { state
                | nextSubscriptions =
                    state.nextSubscriptions
                        |> Dict.insert ( subject, group )
                            { id = subID
                            , subject = subject
                            , group = group
                            , handlers = [ onMessage ]
                            , subType = subType
                            }
                , lastSubID = lastSubID
            }


finalizeSubscriptions : SocketState msg -> ( SocketState msg, List Protocol.Operation )
finalizeSubscriptions state =
    let
        nextSubscriptions =
            state.nextSubscriptions
                |> Dict.values
    in
    ( { state
        | nextSubscriptions =
            state.nextSubscriptions
                |> Dict.filter (\_ -> isRequest)
        , activeSubscriptions = nextSubscriptions
      }
    , (nextSubscriptions
        |> List.filterMap
            (\sub ->
                case getSubscriptionByID sub.id state of
                    Nothing ->
                        Just <| Protocol.SUB sub.subject sub.group sub.id

                    Just _ ->
                        Nothing
            )
      )
        ++ (state.activeSubscriptions
                |> List.filterMap
                    (\sub ->
                        case
                            nextSubscriptions
                                |> List.filter (\next -> next.id == sub.id)
                                |> List.head
                        of
                            Nothing ->
                                Just <| Protocol.UNSUB sub.id 0

                            Just _ ->
                                Nothing
                    )
           )
    )


addRequest :
    { subject : String
    , inbox : String
    , message : String
    , deadline : Int
    , onResponse : Result Timeout String -> msg
    }
    -> SocketState msg
    -> ( SocketState msg, List Protocol.Operation )
addRequest req state =
    ( addSubscriptionHelper
        (Req
            { deadline = req.deadline
            , onTimeout = Err >> req.onResponse
            , onMessage = \m -> ( Just m, False )
            }
        )
        req.inbox
        ""
        (.data >> Ok >> req.onResponse)
        state
    , [ Protocol.PUB
            { subject = req.subject
            , replyTo = req.inbox
            , data = req.message
            }
      ]
    )


parse : String -> SocketState msg -> ( SocketState msg, Maybe Protocol.Operation )
parse str state =
    case Protocol.parseOperation str state.partialOperation of
        Protocol.Operation op ->
            ( { state | partialOperation = Nothing }, Just op )

        Protocol.Partial op ->
            ( { state | partialOperation = Just op }, Nothing )

        Protocol.Error err ->
            ( { state
                | partialOperation = Nothing
                , status = Socket.Error err
              }
            , Nothing
            )


handleTimeouts : Int -> SocketState msg -> ( SocketState msg, List msg )
handleTimeouts time state =
    let
        ( subs, msgList ) =
            state.nextSubscriptions
                |> Dict.foldl
                    (\key sub ( d, msg ) ->
                        case sub.subType of
                            Req { deadline, onTimeout } ->
                                if deadline < time then
                                    ( Dict.insert key { sub | subType = Closed } d
                                    , onTimeout (Time.millisToPosix time) :: msg
                                    )

                                else
                                    ( Dict.insert key sub d, msg )

                            _ ->
                                ( Dict.insert key sub d, msg )
                    )
                    ( Dict.empty, [] )
    in
    ( { state | nextSubscriptions = subs }
    , msgList
    )


receive : String -> SocketState msg -> ( SocketState msg, List msg, List Protocol.Operation )
receive str state =
    let
        ( parseState, maybeOperation ) =
            parse str state
    in
    case maybeOperation of
        Nothing ->
            ( parseState, [], [] )

        Just op ->
            receiveOperation op parseState


receiveOperation : Protocol.Operation -> SocketState msg -> ( SocketState msg, List msg, List Protocol.Operation )
receiveOperation operation state =
    case operation of
        Protocol.INFO serverInfo ->
            ( { state
                | serverInfo = Just serverInfo
              }
            , case state.socket.onOpen of
                Just onOpen ->
                    [ onOpen serverInfo ]

                Nothing ->
                    []
            , Protocol.CONNECT state.socket.connectOptions
                :: (state.activeSubscriptions
                        |> List.map (\sub -> Protocol.SUB sub.subject sub.group sub.id)
                   )
                |> List.reverse
            )

        Protocol.PING ->
            ( state
            , []
            , [ Protocol.PONG ]
            )

        Protocol.MSG id message ->
            case getSubscriptionByID id state of
                Nothing ->
                    ( state, [], [] )

                Just sub ->
                    let
                        ( actualMessage, continue ) =
                            case sub.subType of
                                Req { onMessage } ->
                                    onMessage message

                                Closed ->
                                    ( Nothing, False )

                                Sub ->
                                    ( Just message, True )

                        nextState =
                            if continue then
                                state

                            else
                                { state
                                    | nextSubscriptions =
                                        Dict.insert ( sub.subject, sub.group )
                                            { sub | subType = Closed }
                                            state.nextSubscriptions
                                }
                    in
                    ( nextState
                    , case actualMessage of
                        Nothing ->
                            []

                        Just msg ->
                            sub.handlers
                                |> List.map (\onMessage -> onMessage msg)
                    , []
                    )

        _ ->
            ( state, [], [] )
