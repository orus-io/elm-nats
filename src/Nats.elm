module Nats exposing
    ( open
    , publish
    , subscribe, groupSubscribe
    , request, requestWithTimeout, groupRequest, groupRequestWithTimeout
    , State, Msg
    , Effect, Sub, applyEffectAndSub
    , init, connect, update
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

import Dict exposing (Dict)
import Nats.Config exposing (Config)
import Nats.Errors exposing (Timeout)
import Nats.Internal.SocketState as SocketState exposing (SocketState)
import Nats.Internal.Types as Types exposing (Effect(..), Sub(..))
import Nats.Nuid as Nuid exposing (Nuid)
import Nats.PortsAPI as PortsAPI exposing (Ports)
import Nats.Protocol as Protocol
import Nats.Socket as Socket exposing (Socket)
import Platform.Sub
import Random
import Random.Char
import Random.String
import Task
import Time


{-| A nats effect

Kind of like Cmd, but will be converted at the last moment to regular Cmd

-}
type alias Effect msg =
    Types.Effect msg


{-| A nats subscription

Will be converted at the last moment to regular Sub.

-}
type alias Sub msg =
    Types.Sub msg


{-| A nats internal Msg
-}
type alias Msg msg =
    Types.Msg msg


{-| The nats internal state
-}
type alias State msg =
    { sockets : Dict String (SocketState msg)
    , defaultSocket : Maybe String
    , nuid : Nuid
    , inboxPrefix : String
    , time : Int -- store the time in ms to make deadline calcs simpler
    }


{-| Open a new socket
-}
open : Socket msg -> Effect msg
open =
    Open


{-| Close a socket
-}
close : String -> Effect msg
close =
    Close


{-| Connect the nats internal state to the ports
-}
connect : Config msg -> State msg -> Platform.Sub.Sub msg
connect cfg state =
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
init : Random.Seed -> Time.Posix -> State msg
init seed now =
    let
        ( inboxPrefix, nuid ) =
            Nuid.new seed
                |> Nuid.next
    in
    { sockets = Dict.empty
    , defaultSocket = Nothing
    , nuid = nuid
    , inboxPrefix = inboxPrefix ++ "."
    , time = Time.posixToMillis now
    }


{-| -}
update : Config msg -> Msg msg -> State msg -> ( State msg, Cmd msg )
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
    Config msg
    -> String
    -> (SocketState msg -> ( Maybe (SocketState msg), List msg, Cmd (Msg msg) ))
    -> State msg
    -> ( State msg, List msg, Cmd (Msg msg) )
updateSocket cfg sid fn state =
    case Dict.get sid state.sockets of
        Nothing ->
            ( state, [], Cmd.none )

        Just socket ->
            case fn socket of
                ( Nothing, msgs, cmd ) ->
                    ( { state
                        | sockets = Dict.remove sid state.sockets
                      }
                    , msgs
                    , cmd
                    )

                ( Just newSocket, msgs, cmd ) ->
                    ( { state
                        | sockets = Dict.insert sid newSocket state.sockets
                      }
                    , msgs
                    , cmd
                    )


updateWithEffects : Config msg -> Msg msg -> State msg -> ( State msg, List msg, Cmd (Msg msg) )
updateWithEffects cfg msg state =
    case msg of
        Types.OnOpen sid ->
            ( { state
                | sockets =
                    state.sockets
                        |> Dict.update sid (Maybe.map (SocketState.setStatus Socket.Opened))
              }
            , []
            , Cmd.none
            )

        Types.OnClose sid ->
            state
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
            state
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
            case Dict.get sid state.sockets of
                Nothing ->
                    ( state, [], Cmd.none )

                Just socket ->
                    let
                        ( socketN, msgs, operations ) =
                            SocketState.receive
                                (message
                                    |> cfg.debugLog ("receiving from " ++ sid)
                                )
                                socket
                    in
                    ( { state
                        | sockets =
                            state.sockets
                                |> Dict.insert sid socketN
                      }
                    , msgs
                    , operations
                        |> List.map
                            (\op ->
                                { sid = sid
                                , message =
                                    Protocol.toString op
                                }
                                    |> doSend cfg
                            )
                        |> Cmd.batch
                    )

        Types.OnTime time ->
            let
                msTime =
                    Time.posixToMillis time

                ( sockets, msgs ) =
                    state.sockets
                        |> Dict.foldl
                            (\sid socket ( d, msgList ) ->
                                let
                                    ( s, m ) =
                                        SocketState.handleTimeouts msTime socket
                                in
                                ( Dict.insert sid s d, List.append m msgList )
                            )
                            ( Dict.empty, [] )
            in
            ( { state
                | time = msTime
                , sockets = sockets
              }
            , msgs
            , Cmd.none
            )


nextInbox : State msg -> ( String, State msg )
nextInbox state =
    let
        ( postfix, nuid ) =
            Nuid.next state.nuid
    in
    ( state.inboxPrefix ++ postfix, { state | nuid = nuid } )


toCmd : Config msg -> Effect msg -> State msg -> ( State msg, Cmd msg )
toCmd cfg effect state =
    case effect of
        Open (Types.Socket skt) ->
            ( { state
                | sockets =
                    Dict.insert skt.id
                        (Types.Socket skt
                            |> SocketState.init
                            |> SocketState.setStatus Socket.Opening
                        )
                        state.sockets
                , defaultSocket =
                    if skt.default || state.defaultSocket == Nothing then
                        Just skt.id

                    else
                        state.defaultSocket
              }
            , cfg.ports.open ( skt.id, skt.url )
                |> Cmd.map cfg.parentMsg
            )

        Close sid ->
            case Dict.get sid state.sockets of
                Nothing ->
                    ( state, Cmd.none )

                Just _ ->
                    let
                        sockets =
                            Dict.remove sid state.sockets

                        defaultSocket =
                            if state.defaultSocket /= Just sid then
                                state.defaultSocket

                            else
                                Dict.foldl
                                    (\id s candidate ->
                                        if s.socket.default || candidate == Nothing then
                                            Just id

                                        else
                                            candidate
                                    )
                                    Nothing
                                    sockets
                    in
                    ( { state
                        | sockets = sockets
                        , defaultSocket = defaultSocket
                      }
                    , Cmd.none
                    )

        Pub { sid, subject, replyTo, message } ->
            case sid |> Maybe.withDefault (state.defaultSocket |> Maybe.withDefault "") of
                "" ->
                    let
                        _ =
                            cfg.debugLog "cannot publish message" "Could not determine the sid"
                    in
                    ( state, Cmd.none )

                s ->
                    ( state
                    , doSend cfg
                        { sid = s
                        , message =
                            Protocol.PUB
                                { subject = subject
                                , replyTo = replyTo |> Maybe.withDefault ""
                                , data = message
                                }
                                |> Protocol.toString
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
                    ( state, Cmd.none )

                s ->
                    let
                        ( inbox, state1 ) =
                            nextInbox state

                        ( nextState, msg, cmd ) =
                            state1
                                |> updateSocket cfg
                                    s
                                    (\socket ->
                                        let
                                            ( newSocket, ops ) =
                                                SocketState.addRequest
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
                                                            Protocol.toString op
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
                    ( state, [] )
                |> Tuple.mapSecond Cmd.batch

        NoEffect ->
            ( state, Cmd.none )


handleSub : Config msg -> Sub msg -> State msg -> ( State msg, Cmd msg )
handleSub cfg sub state =
    let
        ( nState, cmd ) =
            handleSubHelper cfg sub state

        ( sockets, opsCmds ) =
            Dict.foldl
                (\sid socket ( newSockets, cmds ) ->
                    let
                        ( nextSocket, nextOps ) =
                            SocketState.finalizeSubscriptions socket

                        nextCmd =
                            nextOps
                                |> List.map
                                    (\op ->
                                        doSend cfg
                                            { sid = sid
                                            , message =
                                                Protocol.toString op
                                            }
                                            |> Cmd.map cfg.parentMsg
                                    )
                    in
                    ( Dict.insert sid nextSocket newSockets, List.append nextCmd cmds )
                )
                ( Dict.empty, [] )
                nState.sockets
    in
    ( { nState
        | sockets = sockets
      }
    , cmd
        :: opsCmds
        |> Cmd.batch
    )


handleSubHelper : Config msg -> Sub msg -> State msg -> ( State msg, Cmd msg )
handleSubHelper cfg sub state =
    case sub of
        Types.Subscribe { sid, subject, group, onMessage } ->
            case sid |> Maybe.withDefault (state.defaultSocket |> Maybe.withDefault "") of
                "" ->
                    let
                        _ =
                            cfg.debugLog "cannot subscribe" "Could not determine the sid"
                    in
                    ( state, Cmd.none )

                s ->
                    let
                        ( newState, _, _ ) =
                            state
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

        Types.BatchSub list ->
            list
                |> List.foldl
                    (\innerSub ( st, cmd ) ->
                        let
                            ( newState, newCmd ) =
                                handleSubHelper cfg innerSub st
                        in
                        ( newState, newCmd :: cmd )
                    )
                    ( state, [] )
                |> Tuple.mapSecond Cmd.batch

        Types.NoSub ->
            ( state, Cmd.none )


{-| Update the nats state according to all the Nats.Effect and Nats.Sub gathered
by the app root component, and emit all the necessary Cmd
-}
applyEffectAndSub : Config msg -> Effect msg -> Sub msg -> State msg -> ( State msg, Cmd msg )
applyEffectAndSub cfg effect sub state =
    let
        ( s1, cmd1 ) =
            toCmd cfg effect state

        ( s2, cmd2 ) =
            handleSub cfg sub s1
    in
    ( s2, Cmd.batch [ cmd1, cmd2 ] )


doSend : Config msg -> PortsAPI.Message -> Cmd (Msg msg)
doSend cfg message =
    let
        _ =
            cfg.debugLog ("sending to " ++ message.sid) message.message
    in
    cfg.ports.send message


{-| Create a request

The timeout is 5s by default

-}
request : String -> String -> (Result Timeout String -> msg) -> Effect msg
request =
    groupRequest ""


{-| Create a request with a custom timeout
-}
requestWithTimeout : Int -> String -> String -> (Result Timeout String -> msg) -> Effect msg
requestWithTimeout =
    groupRequestWithTimeout ""


{-| Create a group request
-}
groupRequest : String -> String -> String -> (Result Timeout String -> msg) -> Effect msg
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
groupRequestWithTimeout : String -> Int -> String -> String -> (Result Timeout String -> msg) -> Effect msg
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
publish : String -> String -> Effect msg
publish subject message =
    Pub { sid = Nothing, subject = subject, replyTo = Nothing, message = message }


{-| Subscribe to a subject

If you wish to subscribe on a non-default socket, use Nats.Sub.onSocket

-}
subscribe : String -> (Protocol.Message -> msg) -> Sub msg
subscribe subject =
    groupSubscribe subject ""


{-| Subscribe to a subject with a group

If you wish to subscribe on a non-default socket, use Nats.Sub.onSocket

-}
groupSubscribe : String -> String -> (Protocol.Message -> msg) -> Sub msg
groupSubscribe subject group onMessage =
    Subscribe { sid = Nothing, subject = subject, group = group, onMessage = onMessage }
