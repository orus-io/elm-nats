module Nats.Internal.SocketState exposing
    ( Msg(..)
    , SocketState
    , SubType(..)
    , SubscriptionState(..)
    , addRequest
    , addSubscription
    , cancelRequest
    , finalizeSubscriptions
    , finalizeTrackers
    , init
    , track
    , update
    )

import Dict exposing (Dict)
import Nats.Errors exposing (Timeout)
import Nats.Events as Events exposing (SocketEvent(..))
import Nats.Internal.Ports as Ports
import Nats.Internal.Types as Types exposing (Config(..))
import Nats.Protocol as Protocol exposing (ConnectOptions)
import Nats.Socket as Socket
import Time


init : ConnectOptions -> (SocketEvent -> msg) -> Types.Socket -> Int -> SocketState datatype msg
init options onEvent (Types.Socket socket) time =
    { socket = socket
    , connectOptions = options
    , onEvent = onEvent
    , status = Socket.Undefined
    , parseState = Protocol.initialParseState
    , serverInfo = Nothing
    , lastSubID = 0
    , activeSubscriptions = []
    , nextSubscriptions = Dict.empty
    , activeTrackers = []
    , nextTrackers = []
    , time = time
    }


type SubType datatype msg
    = Sub (List (Protocol.Message datatype -> msg))
    | Req
        { marker : Maybe String
        , subject : String
        , timeout : Int
        , deadline : Int
        , onTimeout : Time.Posix -> msg
        , onMessage : Protocol.Message datatype -> ( Maybe msg, Bool )
        }


subTypeKey : SubType datatype msg -> String
subTypeKey subType =
    case subType of
        Sub _ ->
            "sub"

        Req _ ->
            "req"


subTypeMerge : SubType datatype msg -> SubType datatype msg -> SubType datatype msg
subTypeMerge sub1 sub2 =
    case ( sub1, sub2 ) of
        ( Sub list1, Sub list2 ) ->
            Sub <| list1 ++ list2

        _ ->
            sub1


type SubscriptionState
    = SubscriptionActive
    | SubscriptionClosed
    | SubscriptionCanceled
    | SubscriptionTimeout


type alias Subscription datatype msg =
    { id : String
    , subject : String
    , group : String
    , subType : SubType datatype msg
    , state : SubscriptionState
    }


type alias SubscriptionKey =
    ( String, String, String )


subscriptionKey : Subscription datatype msg -> SubscriptionKey
subscriptionKey sub =
    ( subTypeKey sub.subType, sub.subject, sub.group )


isActiveRequest : Subscription datatype msg -> Bool
isActiveRequest sub =
    case ( sub.state, sub.subType ) of
        ( SubscriptionActive, Req _ ) ->
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
    , parseState : Protocol.ParseState datatype
    , serverInfo : Maybe Protocol.ServerInfo
    , lastSubID : Int
    , activeSubscriptions : List (Subscription datatype msg)
    , nextSubscriptions : Dict SubscriptionKey (Subscription datatype msg)
    , activeTrackers : List String
    , nextTrackers : List String
    , time : Int
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


getSubscriptionByMarker : String -> SocketState datatype msg -> Maybe (Subscription datatype msg)
getSubscriptionByMarker reqMarker state =
    state.activeSubscriptions
        |> List.filter
            (\sub ->
                case sub.subType of
                    Req { marker } ->
                        marker == Just reqMarker

                    _ ->
                        False
            )
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
addSubscription subject group onMessage =
    addSubscriptionHelper (Sub [ onMessage ]) subject group


addSubscriptionHelper :
    SubType datatype msg
    -> String
    -> String
    -> SocketState datatype msg
    -> SocketState datatype msg
addSubscriptionHelper subType subject group state =
    let
        key : SubscriptionKey
        key =
            ( subTypeKey subType, subject, group )
    in
    case Dict.get key state.nextSubscriptions of
        Just sub ->
            { state
                | nextSubscriptions =
                    state.nextSubscriptions
                        |> Dict.insert key
                            { sub
                                | subType = subTypeMerge sub.subType subType
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
                        |> Dict.insert key
                            { id = subID
                            , subject = subject
                            , group = group
                            , subType = subType
                            , state = SubscriptionActive
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
                        |> Dict.filter (\_ -> isActiveRequest)
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
                                    ( sub.state
                                    , nextSubscriptions
                                        |> List.filter (\next -> next.id == sub.id)
                                        |> List.head
                                    )
                                of
                                    ( SubscriptionCanceled, _ ) ->
                                        Nothing

                                    ( _, Just _ ) ->
                                        Nothing

                                    ( _, Nothing ) ->
                                        Just <| Protocol.UNSUB sub.id 0
                            )
                   )
            )

        _ ->
            ( state, [] )


track : String -> SocketState datatype msg -> SocketState datatype msg
track marker state =
    { state
        | nextTrackers = marker :: state.nextTrackers
    }


finalizeTrackers :
    SocketState datatype msg
    -> ( SocketState datatype msg, List msg, List (Protocol.Operation datatype) )
finalizeTrackers state =
    case state.status of
        Socket.Connected ->
            state.activeTrackers
                |> List.filter
                    -- keep only the trackers that were removed
                    (\marker ->
                        List.filter ((==) marker) state.nextTrackers
                            |> List.isEmpty
                    )
                |> List.foldl
                    -- cancel the corresponding requests
                    (\marker ( st, msgs, ops ) ->
                        let
                            ( nextSt, nextMsgs, nextOps ) =
                                cancelRequest marker st
                        in
                        ( nextSt, msgs ++ nextMsgs, nextOps ++ ops )
                    )
                    ( { state
                        | nextTrackers = []
                        , activeTrackers = state.nextTrackers
                      }
                    , []
                    , []
                    )

        _ ->
            ( state, [], [] )


addRequest :
    Config datatype portdatatype msg
    ->
        { marker : Maybe String
        , subject : String
        , inbox : String
        , message : datatype
        , timeout : Int
        , time : Int
        , onTimeout : Timeout -> msg
        , onResponse : Protocol.Message datatype -> ( Maybe msg, Bool )
        }
    -> SocketState datatype msg
    -> ( SocketState datatype msg, List (Protocol.Operation datatype) )
addRequest (Config cfg) req state =
    ( addSubscriptionHelper
        (Req
            { marker = req.marker
            , subject = req.subject
            , timeout = req.timeout
            , deadline = req.time + req.timeout
            , onTimeout = req.onTimeout
            , onMessage = req.onResponse
            }
        )
        req.inbox
        ""
        state
    , [ Protocol.PUB
            { subject = req.subject
            , replyTo = req.inbox
            , data = req.message
            , size = cfg.size req.message
            }
      ]
    )


cancelRequest :
    String
    -> SocketState datatype msg
    -> ( SocketState datatype msg, List msg, List (Protocol.Operation datatype) )
cancelRequest marker state =
    case
        getSubscriptionByMarker marker state
    of
        Just sub ->
            case sub.subType of
                Req request ->
                    let
                        key : SubscriptionKey
                        key =
                            subscriptionKey sub

                        newSub : Subscription datatype msg
                        newSub =
                            { sub | state = SubscriptionCanceled }

                        newKey : SubscriptionKey
                        newKey =
                            subscriptionKey newSub
                    in
                    ( { state
                        | nextSubscriptions =
                            state.nextSubscriptions
                                |> Dict.remove key
                                |> Dict.insert newKey newSub
                      }
                    , [ state.onEvent <|
                            RequestCancel
                                { sid = state.socket.id
                                , id = sub.id
                                , marker = request.marker
                                , subject = request.subject
                                , inbox = sub.subject
                                }
                      ]
                    , [ Protocol.UNSUB sub.id 0 ]
                    )

                _ ->
                    ( state, [], [] )

        Nothing ->
            ( state, [], [] )


parse : Config datatype portdatatype msg -> datatype -> SocketState datatype msg -> ( SocketState datatype msg, List (Protocol.Operation datatype) )
parse (Config cfg) data state =
    case cfg.parse state.parseState data of
        Ok ( ops, parseState ) ->
            ( { state | parseState = parseState }, ops )

        Err err ->
            ( { state
                | parseState = Protocol.initialParseState
                , status = Socket.Error err
              }
            , []
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
                        case ( sub.state, sub.subType ) of
                            ( SubscriptionActive, Req { deadline, onTimeout } ) ->
                                if deadline < time then
                                    ( Dict.insert key { sub | state = SubscriptionTimeout } d
                                    , onTimeout (Time.millisToPosix time) :: msg
                                    )

                                else
                                    ( Dict.insert key sub d, msg )

                            _ ->
                                ( Dict.insert key sub d, msg )
                    )
                    ( Dict.empty, [] )
    in
    ( { state | nextSubscriptions = subs, time = time }
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
        ( parseState, ops ) =
            parse cfg data state
    in
    ops
        |> List.foldl
            (\op ( st, ( msgs, cmds ) ) ->
                let
                    ( newSt, ( opMsgs, opCmds ) ) =
                        receiveOperation cfg op st
                in
                ( newSt, ( opMsgs ++ msgs, opCmds ++ cmds ) )
            )
            ( parseState, ( [], [] ) )


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
            , ( []
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
                        ( msgList, continue ) =
                            case sub.state of
                                SubscriptionActive ->
                                    case sub.subType of
                                        Req { onMessage } ->
                                            onMessage message
                                                |> Tuple.mapFirst
                                                    (Maybe.map List.singleton
                                                        >> Maybe.withDefault []
                                                    )

                                        Sub handlers ->
                                            ( handlers |> List.map (\onMsg -> onMsg message), True )

                                _ ->
                                    ( [], False )

                        nextState : SocketState datatype msg
                        nextState =
                            let
                                key : SubscriptionKey
                                key =
                                    subscriptionKey sub
                            in
                            if continue then
                                case sub.subType of
                                    Req req ->
                                        { state
                                            | nextSubscriptions =
                                                state.nextSubscriptions
                                                    |> Dict.insert key
                                                        { sub
                                                            | subType =
                                                                Req
                                                                    { req
                                                                        | deadline =
                                                                            state.time + req.timeout
                                                                    }
                                                        }
                                        }

                                    _ ->
                                        state

                            else
                                let
                                    newSub : Subscription datatype msg
                                    newSub =
                                        { sub | state = SubscriptionClosed }

                                    newKey : SubscriptionKey
                                    newKey =
                                        subscriptionKey newSub
                                in
                                { state
                                    | nextSubscriptions =
                                        state.nextSubscriptions
                                            |> Dict.remove key
                                            |> Dict.insert newKey newSub
                                }
                    in
                    ( nextState
                    , ( msgList
                      , []
                      )
                    )

        _ ->
            ( state, ( [], [] ) )
