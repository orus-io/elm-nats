module Nats exposing
    ( connect
    , publish
    , subscribe, groupSubscribe
    , request, requestWithTimeout, customRequest
    , Config, State, Msg
    , Effect, Sub, applyEffectAndSub
    , init, update, subscriptions, activeRequests
    )

{-| A nats.io client for Elm


# socket

@docs connect


# pub/sub/request

@docs publish

@docs subscribe, groupSubscribe

@docs request, requestWithTimeout, customRequest


# Types

@docs Config, State, Msg


# Effects

@docs Effect, Sub, applyEffectAndSub


# ...

@docs init, update, subscriptions, activeRequests

-}

import Nats.Errors exposing (Timeout)
import Nats.Events exposing (SocketEvent)
import Nats.Internal.Ports as Ports
import Nats.Internal.SocketState as SocketState exposing (SocketState)
import Nats.Internal.SocketStateCollection as SocketStateCollection exposing (SocketStateCollection)
import Nats.Internal.Sub as ISub exposing (RealSub(..), Sub(..))
import Nats.Internal.Types as Types exposing (Effect(..))
import Nats.Nuid as Nuid exposing (Nuid)
import Nats.Protocol as Protocol
import Nats.Socket as Socket exposing (Socket)
import Platform.Sub
import Random
import Task
import Time


{-| A nats effect

Kind of like Cmd, but will be converted at the last moment to regular Cmd

-}
type alias Effect datatype msg =
    Types.Effect datatype msg


{-| A nats subscription

Will be converted at the last moment to regular Sub.

-}
type alias Sub datatype msg =
    ISub.Sub datatype msg


{-| A nats internal Msg
-}
type alias Msg datatype msg =
    Types.Msg datatype msg


{-| The NATS configuration
-}
type alias Config datatype portdatatype msg =
    Types.Config datatype portdatatype msg


{-| The nats internal state
-}
type State datatype msg
    = State
        { sockets : SocketStateCollection datatype msg
        , defaultSocket : Maybe String
        , nuid : Nuid
        , inboxPrefix : String
        , time : Int -- store the time in ms to make deadline calcs simpler
        }


onReceive :
    Config datatype portdatatype msg
    -> Ports.Event portdatatype
    -> Msg datatype msg
onReceive (Types.Config cfg) event =
    case ( event.ack, event.open, event.close ) of
        ( Just ack, _, _ ) ->
            Types.OnAck ack

        ( _, Just sid, _ ) ->
            Types.OnOpen sid

        ( _, _, Just sid ) ->
            Types.OnClose sid

        _ ->
            case ( event.error, event.message ) of
                ( Just err, _ ) ->
                    Types.OnError err

                ( _, Just msg ) ->
                    case cfg.fromPortMessage msg.message of
                        Ok message ->
                            Types.OnMessage
                                { sid = msg.sid
                                , ack = msg.ack
                                , message = message
                                }

                        Err err ->
                            Types.OnError
                                { sid = msg.sid
                                , message = "could not decode port message: " ++ err
                                }

                _ ->
                    Types.OnError { sid = "", message = "invalid event coming from the port" }


{-| Connect the nats internal state to the ports
-}
subscriptions : Config datatype portdatatype msg -> State datatype msg -> Platform.Sub.Sub msg
subscriptions ((Types.Config cfg) as ocfg) _ =
    Sub.batch
        [ cfg.ports.receive (onReceive ocfg)
        , Time.every 1000 Types.OnTime
        ]
        |> Sub.map cfg.parentMsg


{-| Initialise a new nats state
-}
init : Random.Seed -> Time.Posix -> State datatype msg
init seed now =
    let
        ( inboxPrefix, nuid ) =
            Nuid.new seed
                |> Nuid.next
    in
    State
        { sockets = SocketStateCollection.empty
        , defaultSocket = Nothing
        , nuid = nuid
        , inboxPrefix = inboxPrefix ++ "."
        , time = Time.posixToMillis now
        }


{-| Handle Nats Msg
-}
update : Config datatype portdatatype msg -> Msg datatype msg -> State datatype msg -> ( State datatype msg, Cmd msg )
update (Types.Config cfg) msg state =
    let
        ( newState, msgs, cmds ) =
            updateWithEffects (Types.Config cfg) msg state
    in
    ( newState
    , Cmd.batch <|
        Cmd.map cfg.parentMsg cmds
            :: (msgs
                    |> List.map (Task.succeed >> Task.perform identity)
               )
    )


updateSocket :
    Config datatype portdatatype msg
    -> String
    -> (SocketState datatype msg -> ( Maybe (SocketState datatype msg), List msg, Cmd (Msg datatype msg) ))
    -> State datatype msg
    -> ( State datatype msg, List msg, Cmd (Msg datatype msg) )
updateSocket _ sid fn ((State state) as oState) =
    case SocketStateCollection.findByID sid state.sockets of
        Nothing ->
            ( oState, [], Cmd.none )

        Just socket ->
            case fn socket of
                ( Nothing, msgs, cmd ) ->
                    ( State
                        { state
                            | sockets = SocketStateCollection.removeByID sid state.sockets
                        }
                    , msgs
                    , cmd
                    )

                ( Just newSocket, msgs, cmd ) ->
                    ( State
                        { state
                            | sockets = SocketStateCollection.insert newSocket state.sockets
                        }
                    , msgs
                    , cmd
                    )


operationToCmd :
    Config datatype portdatatype msg
    -> String
    -> Protocol.Operation datatype
    -> Cmd (Msg datatype msg)
operationToCmd (Types.Config cfg) sid op =
    { sid = sid
    , ack =
        case op of
            Protocol.CONNECT _ ->
                Just "CONNECT"

            _ ->
                Nothing
    , message =
        cfg.write op
    }
        |> doSend (Types.Config cfg)


doUpdateSocket :
    Config datatype portdatatype msg
    -> String
    -> SocketState.Msg datatype
    -> State datatype msg
    -> ( State datatype msg, List msg, Cmd (Msg datatype msg) )
doUpdateSocket ((Types.Config ncfg) as cfg) sid msg (State state) =
    let
        ( sockets, ( msgs, ops ) ) =
            SocketStateCollection.update cfg sid msg state.sockets
    in
    ( State
        { state
            | sockets = sockets
        }
    , msgs
    , ops
        |> List.map ncfg.ports.send
        |> Cmd.batch
    )


doUpdateAllSockets :
    Config datatype portdatatype msg
    -> SocketState.Msg datatype
    -> State datatype msg
    -> ( State datatype msg, List msg, Cmd (Msg datatype msg) )
doUpdateAllSockets ((Types.Config ncfg) as cfg) msg (State state) =
    let
        ( sockets, effects ) =
            state.sockets
                |> SocketStateCollection.mapWithEffect
                    (SocketState.update cfg msg)
    in
    ( State
        { state
            | sockets = sockets
        }
    , effects
        |> List.concatMap Tuple.first
    , effects
        |> List.concatMap Tuple.second
        |> List.map ncfg.ports.send
        |> Cmd.batch
    )


updateWithEffects :
    Config datatype portdatatype msg
    -> Msg datatype msg
    -> State datatype msg
    -> ( State datatype msg, List msg, Cmd (Msg datatype msg) )
updateWithEffects cfg msg ((State state) as oState) =
    case msg of
        Types.OnOpen sid ->
            doUpdateSocket cfg sid SocketState.OnOpen oState

        Types.OnClose sid ->
            doUpdateSocket cfg sid SocketState.OnClose oState

        Types.OnError { sid, message } ->
            doUpdateSocket cfg sid (SocketState.OnError message) oState

        Types.OnMessage { sid, message } ->
            doUpdateSocket cfg sid (SocketState.OnMessage message) oState

        Types.OnAck { sid, ack } ->
            doUpdateSocket cfg sid (SocketState.OnAck ack) oState

        Types.OnTime time ->
            let
                msTime : Int
                msTime =
                    Time.posixToMillis time
            in
            doUpdateAllSockets cfg
                (SocketState.OnTime msTime)
                (State { state | time = msTime })


nextInbox : State datatype msg -> ( String, State datatype msg )
nextInbox (State state) =
    let
        ( postfix, nuid ) =
            Nuid.next state.nuid
    in
    ( state.inboxPrefix ++ postfix, State { state | nuid = nuid } )


toCmd : Config datatype portdatatype msg -> Effect datatype msg -> State datatype msg -> ( State datatype msg, Cmd msg )
toCmd (Types.Config cfg) effect ((State state) as oState) =
    case effect of
        Pub { sid, subject, replyTo, message } ->
            case sid |> Maybe.withDefault (state.defaultSocket |> Maybe.withDefault "") of
                "" ->
                    ( oState
                    , logError (Types.Config cfg) "cannot publish message: Could not determine the sid"
                    )

                s ->
                    ( oState
                    , doSend (Types.Config cfg)
                        { sid = s
                        , ack = Nothing
                        , message =
                            Protocol.PUB
                                { subject = subject
                                , replyTo = replyTo |> Maybe.withDefault ""
                                , data = message
                                , size = cfg.size message
                                }
                                |> cfg.write
                        }
                        |> Cmd.map cfg.parentMsg
                    )

        Request { sid, marker, subject, message, onTimeout, onResponse, timeout } ->
            case sid |> Maybe.withDefault (state.defaultSocket |> Maybe.withDefault "") of
                "" ->
                    ( oState
                    , logError (Types.Config cfg) "cannot publish request: Could not determine the sid"
                    )

                s ->
                    let
                        ( inbox, state1 ) =
                            nextInbox oState

                        ( nextState, _, cmd ) =
                            state1
                                |> updateSocket (Types.Config cfg)
                                    s
                                    (\socket ->
                                        let
                                            ( newSocket, ops ) =
                                                SocketState.addRequest (Types.Config cfg)
                                                    { marker = marker
                                                    , subject = subject
                                                    , inbox = inbox
                                                    , message = message
                                                    , onTimeout = onTimeout
                                                    , onResponse = onResponse
                                                    , timeout = (timeout |> Maybe.withDefault 5) * 1000
                                                    , time = state.time
                                                    }
                                                    socket
                                        in
                                        ( Just <| newSocket
                                        , []
                                        , ops
                                            |> List.map
                                                (\op ->
                                                    doSend (Types.Config cfg)
                                                        { sid = s
                                                        , ack =
                                                            case op of
                                                                Protocol.CONNECT _ ->
                                                                    Just "CONNECT"

                                                                _ ->
                                                                    Nothing
                                                        , message =
                                                            cfg.write op
                                                        }
                                                )
                                            |> Cmd.batch
                                        )
                                    )
                    in
                    ( nextState, Cmd.map cfg.parentMsg cmd )

        BatchEffect list ->
            list
                |> List.foldl
                    (\eff ( st, cmd ) ->
                        let
                            ( newState, newCmd ) =
                                toCmd (Types.Config cfg) eff st
                        in
                        ( newState, newCmd :: cmd )
                    )
                    ( oState, [] )
                |> Tuple.mapSecond Cmd.batch

        NoEffect ->
            ( oState, Cmd.none )


handleSub : Config datatype portdatatype msg -> Sub datatype msg -> State datatype msg -> ( State datatype msg, Cmd msg )
handleSub (Types.Config cfg) (Sub subList) state =
    let
        ( State nState, socketIds, cmds ) =
            subList
                |> List.foldl
                    (\innerSub ( st, socketList, cmdList ) ->
                        let
                            ( newState, socketId, newCmd ) =
                                handleSubHelper (Types.Config cfg) innerSub st
                        in
                        ( newState
                        , case socketId of
                            Nothing ->
                                socketList

                            Just id ->
                                id :: socketList
                        , newCmd :: cmdList
                        )
                    )
                    ( state, [], [] )

        ( sockets, opsCmds ) =
            nState.sockets
                |> SocketStateCollection.mapWithEffect
                    (\socket ->
                        SocketState.finalizeSubscriptions socket
                            |> Tuple.mapSecond
                                (List.map
                                    (operationToCmd (Types.Config cfg) socket.socket.id
                                        >> Cmd.map cfg.parentMsg
                                    )
                                )
                    )
                |> Tuple.mapSecond
                    List.concat

        ( finalSockets, closeCmds ) =
            sockets
                |> SocketStateCollection.toList
                |> List.filter
                    (\socket ->
                        socket.status /= Socket.Closed
                    )
                |> List.map
                    (\socket ->
                        if List.member socket.socket.id socketIds then
                            ( socket, ( [], [] ) )

                        else
                            SocketState.update (Types.Config cfg) SocketState.OnClosing socket
                    )
                |> List.unzip
                |> Tuple.mapFirst SocketStateCollection.fromList
                |> Tuple.mapSecond
                    (List.unzip
                        >> Tuple.mapBoth
                            (List.concat
                                >> List.map (Task.succeed >> Task.perform identity)
                            )
                            (List.concat
                                >> List.map
                                    (cfg.ports.send
                                        >> Cmd.map cfg.parentMsg
                                    )
                            )
                        >> (\( a, b ) -> List.append a b)
                    )
    in
    ( State
        { nState
            | sockets = finalSockets
        }
    , cmds
        ++ opsCmds
        ++ closeCmds
        |> Cmd.batch
    )


handleSubHelper :
    Config datatype portdatatype msg
    -> RealSub datatype msg
    -> State datatype msg
    -> ( State datatype msg, Maybe String, Cmd msg )
handleSubHelper (Types.Config cfg) sub ((State state) as oState) =
    case sub of
        Connect options ((Types.Socket props) as socket) onEvent ->
            case SocketStateCollection.findByID props.id state.sockets of
                Nothing ->
                    -- it's a new connection
                    ( State
                        { state
                            | sockets =
                                state.sockets
                                    |> SocketStateCollection.insert
                                        (SocketState.init options onEvent socket state.time)
                            , defaultSocket =
                                case state.defaultSocket of
                                    Nothing ->
                                        Just props.id

                                    Just id ->
                                        if props.default then
                                            Just props.id

                                        else
                                            Just id
                        }
                    , Just props.id
                    , cfg.ports.send
                        (Ports.open
                            { sid = props.id
                            , url = props.url
                            , mode = cfg.mode
                            , debug = props.debug || cfg.debug
                            }
                        )
                        |> Cmd.map cfg.parentMsg
                    )

                Just _ ->
                    -- TODO if the URL changed, close the socket and re-open
                    ( oState
                    , Just props.id
                    , Cmd.none
                    )

        Subscribe { sid, subject, group, onMessage } ->
            case sid |> Maybe.withDefault (state.defaultSocket |> Maybe.withDefault "") of
                "" ->
                    ( oState
                    , Nothing
                    , logError (Types.Config cfg) "cannot subscribe: Could not determine the sid"
                    )

                s ->
                    let
                        ( newState, _, _ ) =
                            oState
                                |> updateSocket (Types.Config cfg)
                                    s
                                    (\socket ->
                                        ( Just <| SocketState.addSubscription subject group onMessage socket
                                        , []
                                        , Cmd.none
                                        )
                                    )
                    in
                    ( newState, Nothing, Cmd.none )


{-| Update the nats state according to all the Nats.Effect and Nats.Sub gathered
by the app root component, and emit all the necessary Cmd
-}
applyEffectAndSub : Config datatype portdatatype msg -> Effect datatype msg -> Sub datatype msg -> State datatype msg -> ( State datatype msg, Cmd msg )
applyEffectAndSub (Types.Config cfg) effect sub state =
    let
        ( s1, cmd1 ) =
            toCmd (Types.Config cfg) effect state

        ( s2, cmd2 ) =
            handleSub (Types.Config cfg) sub s1
    in
    ( s2, Cmd.batch [ cmd1, cmd2 ] )


{-| List all the active requests
-}
activeRequests :
    State datatype msg
    -> List { sid : String, id : String, marker : Maybe String, subject : String, inbox : String }
activeRequests (State state) =
    state.sockets
        |> SocketStateCollection.toList
        |> List.concatMap
            (\socket ->
                socket.activeSubscriptions
                    |> List.filterMap
                        (\sub ->
                            case sub.subType of
                                SocketState.Req { subject, marker } ->
                                    Just
                                        { sid = socket.socket.id
                                        , id = sub.id
                                        , marker = marker
                                        , subject = subject
                                        , inbox = sub.subject
                                        }

                                _ ->
                                    Nothing
                        )
            )


doSend : Config datatype portdatatype msg -> Ports.Message datatype -> Cmd (Msg datatype msg)
doSend (Types.Config cfg) message =
    { sid = message.sid
    , ack = message.ack
    , message = cfg.toPortMessage message.message
    }
        |> Ports.send
        |> cfg.ports.send


logError : Types.Config datatype portdatatype msg -> String -> Cmd msg
logError (Types.Config cfg) err =
    cfg.onError
        |> Maybe.map
            (\onError ->
                onError err
                    |> Task.succeed
                    |> Task.perform identity
            )
        |> Maybe.withDefault Cmd.none


{-| Open a socket

The socket will be opened as soon as the subscription is active, and until
the subscriptions is removed.

The socket may get closed if a network error occurs, in which case a
'SocketError' event will be sent

After the subscription is removed, the handler will receive a SocketClosed
event.

-}
connect : Protocol.ConnectOptions -> Socket -> (SocketEvent -> msg) -> Sub datatype msg
connect =
    ISub.connect


{-| Create a request

The timeout is 5s by default

-}
request : String -> datatype -> (Result Timeout datatype -> msg) -> Effect datatype msg
request subject message onResponse =
    Request
        { sid = Nothing
        , marker = Nothing
        , subject = subject
        , message = message
        , onTimeout = Err >> onResponse
        , onResponse =
            \msg ->
                ( Just <| onResponse <| Ok msg.data, False )
        , timeout = Nothing
        }


{-| Create a request with a custom timeout
-}
requestWithTimeout : Int -> String -> datatype -> (Result Timeout datatype -> msg) -> Effect datatype msg
requestWithTimeout timeout subject message onResponse =
    Request
        { sid = Nothing
        , marker = Nothing
        , subject = subject
        , message = message
        , onTimeout = Err >> onResponse
        , onResponse =
            \msg ->
                ( Just <| onResponse <| Ok msg.data, False )
        , timeout = Just timeout
        }


{-| Create a request with custom features
-}
customRequest :
    { marker : String
    , subject : String
    , message : datatype
    , onTimeout : Timeout -> msg
    , onResponse : Protocol.Message datatype -> ( Maybe msg, Bool )
    , timeout : Maybe Int
    }
    -> Effect datatype msg
customRequest { marker, subject, message, onTimeout, onResponse, timeout } =
    Request
        { sid = Nothing
        , marker = Just marker
        , subject = subject
        , message = message
        , onTimeout = onTimeout
        , onResponse = onResponse
        , timeout = timeout
        }


{-| Publish a new message on a given subject

If you wish to send it on a non-default socket, use Nats.Effect.onSocket

-}
publish : String -> datatype -> Effect datatype msg
publish subject message =
    Pub { sid = Nothing, subject = subject, replyTo = Nothing, message = message }


{-| Subscribe to a subject

If you wish to subscribe on a non-default socket, use Nats.Sub.onSocket

-}
subscribe : String -> (Protocol.Message datatype -> msg) -> Sub datatype msg
subscribe subject =
    groupSubscribe subject ""


{-| Subscribe to a subject with a group

If you wish to subscribe on a non-default socket, use Nats.Sub.onSocket

-}
groupSubscribe : String -> String -> (Protocol.Message datatype -> msg) -> Sub datatype msg
groupSubscribe subject group onMessage =
    ISub.subscribe { sid = Nothing, subject = subject, group = group, onMessage = onMessage }
