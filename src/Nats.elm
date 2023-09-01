module Nats exposing
    ( publish
    , subscribe, groupSubscribe
    , request, requestWithTimeout, groupRequest, groupRequestWithTimeout
    , State, Msg
    , Effect, Sub, applyEffectAndSub
    , init, connect, update
    , subscriptions
    )

{-| A nats.io client for Elm


# pub/sub/request

@docs open

@docs publish

@docs subscribe, groupSubscribe

@docs request, requestWithTimeout, groupRequest, groupRequestWithTimeout


# Types

@docs State, Msg


# Effects

@docs Effect, Sub, applyEffectAndSub


# ...

@docs init, connect, update

-}

import Nats.Config exposing (Config)
import Nats.Errors exposing (Timeout)
import Nats.Events as Events exposing (SocketEvent(..))
import Nats.Internal.SocketState as SocketState exposing (SocketState)
import Nats.Internal.SocketStateCollection as SocketStateCollection exposing (SocketStateCollection)
import Nats.Internal.Sub as ISub exposing (RealSub(..), Sub(..))
import Nats.Internal.Types as Types exposing (Effect(..))
import Nats.Nuid as Nuid exposing (Nuid)
import Nats.PortsAPI as PortsAPI
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
type alias Msg msg =
    Types.Msg msg


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


{-| Connect the nats internal state to the ports
-}
subscriptions : Config datatype msg -> State datatype msg -> Platform.Sub.Sub msg
subscriptions cfg _ =
    Sub.batch
        [ cfg.ports.onOpen Types.OnOpen
        , cfg.ports.onClose Types.OnClose
        , cfg.ports.onError Types.OnError
        , cfg.ports.onMessage Types.OnMessage
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


{-| -}
update : Config datatype msg -> Msg msg -> State datatype msg -> ( State datatype msg, Cmd msg )
update cfg msg state =
    let
        ( newState, msgs, cmds ) =
            updateWithEffects cfg msg state
    in
    ( newState
    , Cmd.batch <|
        Cmd.map cfg.parentMsg cmds
            :: (msgs
                    |> List.map (Task.succeed >> Task.perform identity)
               )
    )


updateSocket :
    Config datatype msg
    -> String
    -> (SocketState datatype msg -> ( Maybe (SocketState datatype msg), List msg, Cmd (Msg msg) ))
    -> State datatype msg
    -> ( State datatype msg, List msg, Cmd (Msg msg) )
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


updateWithEffects : Config datatype msg -> Msg msg -> State datatype msg -> ( State datatype msg, List msg, Cmd (Msg msg) )
updateWithEffects cfg msg ((State state) as oState) =
    case msg of
        Types.OnOpen sid ->
            ( State
                { state
                    | sockets =
                        state.sockets
                            |> SocketStateCollection.update sid
                                (SocketState.setStatus Socket.Opened)
                }
            , []
            , Cmd.none
            )

        Types.OnClose sid ->
            oState
                |> updateSocket cfg
                    sid
                    (\socket ->
                        case socket.status of
                            Socket.Closing ->
                                ( Nothing, [], Cmd.none )

                            _ ->
                                ( Just <|
                                    SocketState.setStatus
                                        (Socket.Error "socket closed")
                                        socket
                                , []
                                , Cmd.none
                                )
                    )

        Types.OnError { sid, message } ->
            oState
                |> updateSocket cfg
                    sid
                    (\socket ->
                        ( Just <|
                            SocketState.setStatus
                                (Socket.Error message)
                                socket
                        , []
                        , Cmd.none
                        )
                    )

        Types.OnMessage { sid, message } ->
            case SocketStateCollection.findByID sid state.sockets of
                Nothing ->
                    ( oState, [], Cmd.none )

                Just socket ->
                    case message |> cfg.fromPortMessage of
                        Ok data ->
                            let
                                ( socketN, msgs, operations ) =
                                    SocketState.receive cfg
                                        data
                                        socket
                            in
                            ( State
                                { state
                                    | sockets =
                                        state.sockets
                                            |> SocketStateCollection.insert socketN
                                }
                            , msgs
                            , operations
                                |> List.map
                                    (\op ->
                                        { sid = sid
                                        , message =
                                            cfg.write op
                                                |> cfg.toPortMessage
                                        }
                                            |> doSend cfg
                                    )
                                |> Cmd.batch
                            )

                        Err err ->
                            ( oState
                            , [ socket.onEvent (Events.SocketError err)
                              ]
                            , Cmd.none
                            )

        Types.OnTime time ->
            let
                msTime =
                    Time.posixToMillis time

                ( sockets, msgs ) =
                    state.sockets
                        |> SocketStateCollection.mapWithEffect
                            (SocketState.handleTimeouts msTime)
            in
            ( State
                { state
                    | time = msTime
                    , sockets = sockets
                }
            , msgs |> List.concat
            , Cmd.none
            )


nextInbox : State datatype msg -> ( String, State datatype msg )
nextInbox (State state) =
    let
        ( postfix, nuid ) =
            Nuid.next state.nuid
    in
    ( state.inboxPrefix ++ postfix, State { state | nuid = nuid } )


toCmd : Config datatype msg -> Effect datatype msg -> State datatype msg -> ( State datatype msg, Cmd msg )
toCmd cfg effect ((State state) as oState) =
    case effect of
        Pub { sid, subject, replyTo, message } ->
            case sid |> Maybe.withDefault (state.defaultSocket |> Maybe.withDefault "") of
                "" ->
                    let
                        _ =
                            cfg.debugLog "cannot publish message" "Could not determine the sid"
                    in
                    ( oState, Cmd.none )

                s ->
                    ( oState
                    , doSend cfg
                        { sid = s
                        , message =
                            Protocol.PUB
                                { subject = subject
                                , replyTo = replyTo |> Maybe.withDefault ""
                                , data = message
                                , size = cfg.size message
                                }
                                |> cfg.write
                                |> cfg.toPortMessage
                        }
                        |> Cmd.map cfg.parentMsg
                    )

        Request { sid, subject, message, onResponse, timeout } ->
            case sid |> Maybe.withDefault (state.defaultSocket |> Maybe.withDefault "") of
                "" ->
                    let
                        _ =
                            cfg.debugLog "cannot publish message" "Could not determine the sid"
                    in
                    ( oState, Cmd.none )

                s ->
                    let
                        ( inbox, state1 ) =
                            nextInbox oState

                        ( nextState, msg, cmd ) =
                            state1
                                |> updateSocket cfg
                                    s
                                    (\socket ->
                                        let
                                            ( newSocket, ops ) =
                                                SocketState.addRequest cfg
                                                    { subject = subject
                                                    , inbox = inbox
                                                    , message = message
                                                    , onResponse = onResponse
                                                    , deadline = state.time + 1000 * (timeout |> Maybe.withDefault 5)
                                                    }
                                                    socket
                                        in
                                        ( Just <| newSocket
                                        , []
                                        , ops
                                            |> List.map
                                                (\op ->
                                                    doSend cfg
                                                        { sid = s
                                                        , message =
                                                            cfg.write op
                                                                |> cfg.toPortMessage
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
                                toCmd cfg eff st
                        in
                        ( newState, newCmd :: cmd )
                    )
                    ( oState, [] )
                |> Tuple.mapSecond Cmd.batch

        NoEffect ->
            ( oState, Cmd.none )


handleSub : Config datatype msg -> Sub datatype msg -> State datatype msg -> ( State datatype msg, Cmd msg )
handleSub cfg (Sub subList) state =
    let
        ( State nState, cmd ) =
            subList
                |> List.foldl
                    (\innerSub ( st, cmdList ) ->
                        let
                            ( newState, newCmd ) =
                                handleSubHelper cfg innerSub st
                        in
                        ( newState, newCmd :: cmdList )
                    )
                    ( state, [] )
                |> Tuple.mapSecond Cmd.batch

        ( sockets, opsCmds ) =
            nState.sockets
                |> SocketStateCollection.mapWithEffect
                    (\socket ->
                        SocketState.finalizeSubscriptions socket
                            |> Tuple.mapSecond
                                (List.map
                                    (\op ->
                                        doSend cfg
                                            { sid = socket.socket.id
                                            , message =
                                                cfg.write op
                                                    |> cfg.toPortMessage
                                            }
                                            |> Cmd.map cfg.parentMsg
                                    )
                                )
                    )
                |> Tuple.mapSecond List.concat
    in
    ( State
        { nState
            | sockets = sockets
        }
    , cmd
        :: opsCmds
        |> Cmd.batch
    )


handleSubHelper : Config datatype msg -> RealSub datatype msg -> State datatype msg -> ( State datatype msg, Cmd msg )
handleSubHelper cfg sub ((State state) as oState) =
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
                                        (SocketState.init options onEvent socket)
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
                    , cfg.ports.open ( props.id, props.url )
                        |> Cmd.map cfg.parentMsg
                    )

                Just _ ->
                    -- TODO if the URL changed, close the socket and re-open
                    ( oState
                    , Cmd.none
                    )

        Subscribe { sid, subject, group, onMessage } ->
            case sid |> Maybe.withDefault (state.defaultSocket |> Maybe.withDefault "") of
                "" ->
                    let
                        _ =
                            cfg.debugLog "cannot subscribe" "Could not determine the sid"
                    in
                    ( oState, Cmd.none )

                s ->
                    let
                        ( newState, _, _ ) =
                            oState
                                |> updateSocket cfg
                                    s
                                    (\socket ->
                                        ( Just <| SocketState.addSubscription subject group onMessage socket
                                        , []
                                        , Cmd.none
                                        )
                                    )
                    in
                    ( newState, Cmd.none )


{-| Update the nats state according to all the Nats.Effect and Nats.Sub gathered
by the app root component, and emit all the necessary Cmd
-}
applyEffectAndSub : Config datatype msg -> Effect datatype msg -> Sub datatype msg -> State datatype msg -> ( State datatype msg, Cmd msg )
applyEffectAndSub cfg effect sub state =
    let
        ( s1, cmd1 ) =
            toCmd cfg effect state

        ( s2, cmd2 ) =
            handleSub cfg sub s1
    in
    ( s2, Cmd.batch [ cmd1, cmd2 ] )


doSend : Config datatype msg -> PortsAPI.Message -> Cmd (Msg msg)
doSend cfg message =
    let
        _ =
            cfg.debugLog ("sending to " ++ message.sid) message.message
    in
    cfg.ports.send message


connect : Protocol.ConnectOptions -> Socket -> (SocketEvent -> msg) -> Sub datatype msg
connect =
    ISub.connect


{-| Create a request

The timeout is 5s by default

-}
request : String -> datatype -> (Result Timeout datatype -> msg) -> Effect datatype msg
request =
    groupRequest ""


{-| Create a request with a custom timeout
-}
requestWithTimeout : Int -> String -> datatype -> (Result Timeout datatype -> msg) -> Effect datatype msg
requestWithTimeout =
    groupRequestWithTimeout ""


{-| Create a group request
-}
groupRequest : String -> String -> datatype -> (Result Timeout datatype -> msg) -> Effect datatype msg
groupRequest group subject message onResponse =
    Request
        { sid = Nothing
        , subject = subject
        , group = group
        , message = message
        , onResponse = onResponse
        , timeout = Nothing
        }


{-| Create a group request with a custom timeout
-}
groupRequestWithTimeout : String -> Int -> String -> datatype -> (Result Timeout datatype -> msg) -> Effect datatype msg
groupRequestWithTimeout group timeout subject message onResponse =
    Request
        { sid = Nothing
        , subject = subject
        , group = group
        , message = message
        , onResponse = onResponse
        , timeout = Just timeout
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
    Sub [ Subscribe { sid = Nothing, subject = subject, group = group, onMessage = onMessage } ]
