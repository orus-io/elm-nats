module Nats.Internal.SocketState exposing
    ( Msg(..)
    , SocketState
    , addRequest
    , addSubscription
    , finalizeSubscriptions
    , init
    , update
    )

import Dict exposing (Dict)
import Nats.Errors exposing (Timeout)
import Nats.Events as Events exposing (SocketEvent)
import Nats.Internal.Ports as Ports
import Nats.Internal.Types as Types exposing (Config(..))
import Nats.Protocol as Protocol exposing (ConnectOptions)
import Nats.Socket as Socket
import Time


init : ConnectOptions -> (SocketEvent -> msg) -> Types.Socket -> SocketState datatype msg
init options onEvent (Types.Socket socket) =
    { socket = socket
    , connectOptions = options
    , onEvent = onEvent
    , status = Socket.Undefined
    , partialOperation = Nothing
    , serverInfo = Nothing
    , lastSubID = 0
    , activeSubscriptions = []
    , nextSubscriptions = Dict.empty
    }


type SubType datatype msg
    = Closed
    | Sub
    | Req
        { deadline : Int
        , onTimeout : Time.Posix -> msg
        , onMessage : Protocol.Message datatype -> ( Maybe (Protocol.Message datatype), Bool )
        }


type alias Subscription datatype msg =
    { id : String
    , subject : String
    , group : String
    , handlers : List (Protocol.Message datatype -> msg)
    , subType : SubType datatype msg
    }


isRequest : Subscription datatype msg -> Bool
isRequest sub =
    case sub.subType of
        Req _ ->
            True

        _ ->
            False


type Msg datatype
    = OnOpen
    | OnClosing
    | OnClose
    | OnError String
    | OnMessage datatype
    | OnAck String
    | OnTime Int


type alias SocketState datatype msg =
    { socket : Types.SocketProps
    , connectOptions : ConnectOptions
    , onEvent : SocketEvent -> msg
    , status : Socket.Status
    , partialOperation : Maybe (Protocol.PartialOperation datatype)
    , serverInfo : Maybe Protocol.ServerInfo
    , lastSubID : Int
    , activeSubscriptions : List (Subscription datatype msg)
    , nextSubscriptions : Dict ( String, String ) (Subscription datatype msg)

    -- , lastSeen : Maybe Time
    }


update :
    Config datatype portdatatype msg
    -> Msg datatype
    -> SocketState datatype msg
    ->
        ( SocketState datatype msg
        , ( List msg
          , List (Ports.Command portdatatype)
          )
        )
update cfg msg state =
    case msg of
        OnOpen ->
            ( state |> setStatus Socket.Opened, ( [], [] ) )

        OnClosing ->
            ( state |> setStatus Socket.Closing
            , ( []
              , [ Ports.close state.socket.id ]
              )
            )

        OnClose ->
            ( state |> setStatus Socket.Closed
            , ( [ state.onEvent <| Events.SocketClose
                ]
              , []
              )
            )

        OnError err ->
            ( state |> setStatus (Socket.Error err)
            , ( [ state.onEvent <| Events.SocketError err
                ]
              , []
              )
            )

        OnMessage message ->
            receive cfg message state

        OnAck ack ->
            case ack of
                "CONNECT" ->
                    ( ackCONNECT state
                    , ( case state.serverInfo of
                            Just info ->
                                [ state.onEvent <| Events.SocketOpen info ]

                            Nothing ->
                                []
                      , []
                      )
                    )

                _ ->
                    ( state
                    , ( []
                      , []
                      )
                    )

        OnTime time ->
            handleTimeouts time state


setStatus : Socket.Status -> SocketState datatype msg -> SocketState datatype msg
setStatus status state =
    { state
        | status = status
    }


getSubscriptionByID : String -> SocketState datatype msg -> Maybe (Subscription datatype msg)
getSubscriptionByID id state =
    state.activeSubscriptions
        |> List.filter (.id >> (==) id)
        |> List.head


getSubscriptionBySubjectGroup : ( String, String ) -> SocketState datatype msg -> Maybe (Subscription datatype msg)
getSubscriptionBySubjectGroup ( subject, group ) state =
    state.activeSubscriptions
        |> List.filter (\sub -> ( sub.subject, sub.group ) == ( subject, group ))
        |> List.head


nextID : SocketState datatype msg -> Int
nextID state =
    state.lastSubID + 1


addSubscription : String -> String -> (Protocol.Message datatype -> msg) -> SocketState datatype msg -> SocketState datatype msg
addSubscription =
    addSubscriptionHelper Sub


addSubscriptionHelper : SubType datatype msg -> String -> String -> (Protocol.Message datatype -> msg) -> SocketState datatype msg -> SocketState datatype msg
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


finalizeSubscriptions :
    SocketState datatype msg
    -> ( SocketState datatype msg, List (Protocol.Operation datatype) )
finalizeSubscriptions state =
    case state.status of
        Socket.Connected ->
            let
                nextSubscriptions : List (Subscription datatype msg)
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

        _ ->
            ( state, [] )


addRequest :
    Config datatype portdatatype msg
    ->
        { subject : String
        , inbox : String
        , message : datatype
        , deadline : Int
        , onResponse : Result Timeout datatype -> msg
        }
    -> SocketState datatype msg
    -> ( SocketState datatype msg, List (Protocol.Operation datatype) )
addRequest (Config cfg) req state =
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
            , size = cfg.size req.message
            }
      ]
    )


parse : Config datatype portdatatype msg -> datatype -> SocketState datatype msg -> ( SocketState datatype msg, Maybe (Protocol.Operation datatype) )
parse (Config cfg) data state =
    case cfg.parse data state.partialOperation of
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


handleTimeouts :
    Int
    -> SocketState datatype msg
    -> ( SocketState datatype msg, ( List msg, List (Ports.Command portdatatype) ) )
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
    , ( msgList
      , []
      )
    )


receive :
    Config datatype portdatatype msg
    -> datatype
    -> SocketState datatype msg
    ->
        ( SocketState datatype msg
        , ( List msg
          , List (Ports.Command portdatatype)
          )
        )
receive cfg data state =
    let
        ( parseState, maybeOperation ) =
            parse cfg data state
    in
    case maybeOperation of
        Nothing ->
            ( parseState, ( [], [] ) )

        Just op ->
            receiveOperation cfg op parseState


ackCONNECT : SocketState datatype msg -> SocketState datatype msg
ackCONNECT =
    setStatus Socket.Connected


operationToPortCommand :
    Config datatype portdatatype msg
    -> String
    -> Protocol.Operation datatype
    -> Ports.Command portdatatype
operationToPortCommand (Types.Config ncfg) sid op =
    { sid = sid
    , ack =
        case op of
            Protocol.CONNECT _ ->
                Just "CONNECT"

            _ ->
                Nothing
    , message =
        op
            |> ncfg.write
            |> ncfg.toPortMessage
    }
        |> Ports.send


receiveOperation :
    Config datatype portdatatype msg
    -> Protocol.Operation datatype
    -> SocketState datatype msg
    -> ( SocketState datatype msg, ( List msg, List (Ports.Command portdatatype) ) )
receiveOperation cfg operation state =
    case operation of
        Protocol.INFO serverInfo ->
            ( { state
                | serverInfo = Just serverInfo
              }
                |> setStatus Socket.Connecting
            , ( [ Events.SocketOpen serverInfo |> state.onEvent ]
              , [ Protocol.CONNECT state.connectOptions
                    |> operationToPortCommand cfg state.socket.id
                ]
              )
            )

        Protocol.PING ->
            ( state
            , ( []
              , [ Protocol.PONG
                    |> operationToPortCommand cfg state.socket.id
                ]
              )
            )

        Protocol.MSG id message ->
            case getSubscriptionByID id state of
                Nothing ->
                    ( state, ( [], [] ) )

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

                        nextState : SocketState datatype msg
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
                    , ( case actualMessage of
                            Nothing ->
                                []

                            Just msg ->
                                sub.handlers
                                    |> List.map (\onMessage -> onMessage msg)
                      , []
                      )
                    )

        _ ->
            ( state, ( [], [] ) )
