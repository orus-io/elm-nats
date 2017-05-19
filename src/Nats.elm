module Nats
    exposing
        ( State
        , Msg
        , init
        , update
        , listen
        , publish
        , subscribe
        , queuesubscribe
        , request
        , merge
        )

{-| This library provides a pure elm implementation of the NATS client
protocol on top of WebSocket.

The NATS server does not support websocket natively, so a NATS/websocket
proxy must be used. The only compatible one is
<https://github.com/orus-io/nats-websocket-gw>


# Types

@docs State, Msg


# Operations

@docs subscribe, queuesubscribe, publish, request


# TEA entry points

@docs init, update, merge, listen

-}

import Debug
import WebSocket
import Dict exposing (Dict)
import Time
import Random
import Random.Char
import Random.String
import Task
import Nats.Protocol as Protocol
import Nats.Cmd as NatsCmd
import Nats.Sub as NatsSub


{-| Type of message the update function takes
-}
type Msg
    = Receive Protocol.Operation
    | ReceptionError String
    | RequestInbox ( String, String ) String String
    | RequestResponse Sid Protocol.Message
    | KeepAlive Time.Time


type alias Sid =
    String


{-| A NATS subscription
-}
type alias Subscription msg =
    { subject : String
    , tag : String
    , requestBounded : Bool
    , queueGroup : String
    , sid : Sid
    , translate : Protocol.Message -> msg
    }


{-| The NATS state to add to the application model (once)
-}
type alias State msg =
    { url : String
    , tagger : Msg -> msg
    , keepAlive : Time.Time
    , sidCounter : Int
    , subscriptions : Dict Sid (Subscription msg)
    , serverInfo : Maybe Protocol.ServerInfo
    , inboxPrefix : String
    }


receive : State msg -> (Msg -> msg) -> Result String Protocol.Operation -> msg
receive state convert operation =
    case operation of
        Err err ->
            convert <| ReceptionError err

        Ok operation ->
            case operation of
                Protocol.MSG sid natsMsg ->
                    case Dict.get sid state.subscriptions of
                        Just sub ->
                            if sub.requestBounded then
                                convert <| RequestResponse sid natsMsg
                            else
                                sub.translate natsMsg

                        Nothing ->
                            convert <| Receive operation

                _ ->
                    convert <| Receive operation


{-| Creates a Sub for the whole applications
It takes a list of all the active subscriptions from all the application
parts, which are used to translate the WebSocket message into the message
type each component need.
-}
listen : State msg -> Sub msg
listen state =
    Sub.batch
        [ WebSocket.listen
            state.url
            (Debug.log "Receiving" >> Protocol.parseOperation >> receive state state.tagger)
        , Time.every state.keepAlive (KeepAlive >> state.tagger)
        ]


{-| Initialize a Nats State for a given websocket URL
-}
init : (Msg -> msg) -> String -> State msg
init tagger url =
    { url = url
    , tagger = tagger
    , keepAlive = 5 * Time.minute
    , sidCounter = 0
    , subscriptions = Dict.empty
    , serverInfo = Nothing
    , inboxPrefix = "_INBOX."
    }


send : State msg -> Protocol.Operation -> Cmd Msg
send state op =
    Protocol.toString op |> Debug.log "Sending" |> WebSocket.send state.url


sendAll : State msg -> List Protocol.Operation -> Cmd Msg
sendAll state ops =
    (String.join "" <|
        List.map Protocol.toString ops
    )
        |> WebSocket.send state.url


sendMsg : msg -> Cmd msg
sendMsg msg =
    Task.perform identity <| Task.succeed msg


{-| The update function
Will make sure PING commands from the server are honored with a PONG,
and send a PING to keep the connection alive.
-}
update : Msg -> State msg -> ( State msg, Cmd msg )
update msg state =
    case msg of
        Receive op ->
            case op of
                Protocol.PING ->
                    state ! [ Cmd.map state.tagger <| send state Protocol.PONG ]

                Protocol.INFO serverInfo ->
                    { state | serverInfo = Just serverInfo } ! []

                _ ->
                    state ! []

        ReceptionError err ->
            state ! []

        RequestInbox ( subject, data ) sid inboxSuffix ->
            case Dict.get sid state.subscriptions of
                Just sub ->
                    let
                        newSub =
                            { sub | subject = state.inboxPrefix ++ inboxSuffix }
                    in
                        { state
                            | subscriptions = Dict.insert sid newSub state.subscriptions
                        }
                            ! [ Cmd.map state.tagger <|
                                    sendAll state
                                        [ Protocol.SUB newSub.subject newSub.queueGroup newSub.sid
                                        , Protocol.PUB
                                            { subject = subject
                                            , replyTo = newSub.subject
                                            , data = data
                                            }
                                        ]
                              ]

                Nothing ->
                    -- TODO report an error somehow ? crash the app ?
                    state ! []

        RequestResponse sid natsMsg ->
            case Dict.get sid state.subscriptions of
                Just sub ->
                    { state
                        | subscriptions = Dict.remove sid state.subscriptions
                    }
                        ! [ sendMsg <| sub.translate natsMsg ]

                Nothing ->
                    state ! []

        KeepAlive _ ->
            state ! [ Cmd.map state.tagger <| send state Protocol.PING ]


splitSubject : String -> ( String, String )
splitSubject s =
    let
        sp =
            String.split "#" s
    in
        ( Maybe.withDefault "" (List.head sp)
        , Maybe.withDefault "" (List.head <| Maybe.withDefault [] <| List.tail sp)
        )


initSubscription : String -> String -> Bool -> (Protocol.Message -> msg) -> Subscription msg
initSubscription subject queueGroup requestBounded translate =
    let
        ( cleanSubject, tag ) =
            splitSubject subject
    in
        { subject = cleanSubject
        , tag = tag
        , requestBounded = requestBounded
        , queueGroup = queueGroup
        , sid = ""
        , translate = translate
        }


{-| a basic nats subscription
-}
subscribe : String -> (Protocol.Message -> msg) -> NatsSub.Sub msg
subscribe subject tagger =
    NatsSub.Subscribe subject "" tagger


{-| a queue nats subscription
-}
queuesubscribe : String -> String -> (Protocol.Message -> msg) -> NatsSub.Sub msg
queuesubscribe subject queueGroup tagger =
    NatsSub.Subscribe subject queueGroup tagger


applyNatsSub : State msg -> NatsSub.Sub msg -> ( List String, State msg, List (Cmd Msg) )
applyNatsSub state sub =
    -- for each sub, check if it already exists. If not, add it and send a SUB
    -- return updated state and a list of sid
    case sub of
        NatsSub.None ->
            ( [], state, [] )

        NatsSub.BatchSub list ->
            List.foldl
                (\sub ( sids, state, cmds ) ->
                    let
                        ( nSids, nState, nCmds ) =
                            applyNatsSub state sub
                    in
                        ( sids ++ nSids, nState, cmds ++ nCmds )
                )
                ( [], state, [] )
                list

        NatsSub.Subscribe subject queueGroup tagger ->
            let
                ( cleanSubject, tag ) =
                    splitSubject subject
            in
                case
                    List.head <|
                        List.filter
                            (\sub ->
                                sub.subject == cleanSubject && sub.queueGroup == queueGroup && sub.tag == tag
                            )
                            (Dict.values state.subscriptions)
                of
                    Just sub ->
                        ( [ sub.sid ], state, [] )

                    Nothing ->
                        let
                            ( nSub, nState, cmd ) =
                                initSubscription subject queueGroup False tagger
                                    |> setupSubscription state
                        in
                            ( [ nSub.sid ], nState, [ cmd ] )


cleanSubs : State msg -> List String -> ( State msg, List (Cmd Msg) )
cleanSubs state sids =
    let
        ( keep, remove ) =
            Dict.partition
                (\sid v ->
                    v.requestBounded || List.member sid sids
                )
                state.subscriptions
    in
        ( { state
            | subscriptions = keep
          }
        , List.map ((flip Protocol.UNSUB) 0 >> send state) <| Dict.keys remove
        )


mergeNatsSub : State msg -> NatsSub.Sub msg -> ( State msg, Cmd Msg )
mergeNatsSub state sub =
    -- apply the sub
    -- for each establish sub without an incoming sub, delete it and send a UNSUB
    let
        ( sids, nState, subCmds ) =
            applyNatsSub state sub

        ( finalState, unsubCmds ) =
            cleanSubs nState sids
    in
        ( finalState, Cmd.batch (subCmds ++ unsubCmds) )


{-| Apply NatsCmd in the Nats State and return somd actual Cmd
-}
mergeNatsCmd : State msg -> NatsCmd.Cmd msg -> ( State msg, Cmd Msg )
mergeNatsCmd state cmd =
    case cmd of
        NatsCmd.Publish subject data ->
            state
                ! [ send state <|
                        Protocol.PUB
                            { subject = subject
                            , replyTo = ""
                            , data = data
                            }
                  ]

        NatsCmd.Request subject data translate ->
            -- prepare a subject-less subscription
            -- get a random id
            let
                ( sub, newState, cmd ) =
                    setupSubscription state <|
                        initSubscription "" "" True translate
            in
                newState
                    ! [ Random.generate (RequestInbox ( subject, data ) sub.sid) <|
                            Random.String.string 12 Random.Char.latin
                      ]

        NatsCmd.Batch natsCmds ->
            let
                folder natsCmd ( state, cmds ) =
                    let
                        ( newState, cmd ) =
                            mergeNatsCmd state natsCmd
                    in
                        ( newState, cmd :: cmds )

                ( newState, cmds ) =
                    List.foldl folder ( state, [] ) natsCmds
            in
                newState ! cmds

        NatsCmd.None ->
            state ! []


{-| merges nats subscriptions and commands into a Nats State, and returns
a Cmd Msg for side effects.
-}
merge : State msg -> NatsSub.Sub msg -> NatsCmd.Cmd msg -> ( State msg, Cmd msg )
merge state sub cmd =
    let
        ( subState, subCmd ) =
            mergeNatsSub state sub

        ( cmdState, cmdCmd ) =
            mergeNatsCmd subState cmd
    in
        ( cmdState, Cmd.map state.tagger <| Cmd.batch [ subCmd, cmdCmd ] )


{-| Add a subscription to the State
-}
setupSubscription : State msg -> Subscription msg -> ( Subscription msg, State msg, Cmd Msg )
setupSubscription state subscription =
    let
        sub : Subscription msg
        sub =
            { subscription
                | sid = toString state.sidCounter
            }
    in
        ( sub
        , { state
            | sidCounter = state.sidCounter + 1
            , subscriptions = Dict.insert sub.sid sub state.subscriptions
          }
        , send state <| Protocol.SUB sub.subject sub.queueGroup sub.sid
        )


{-| Publish a message on a subject
-}
publish : String -> String -> NatsCmd.Cmd msg
publish subject data =
    NatsCmd.Publish subject data


{-| Send a request an return the response in a msg
-}
request : String -> String -> (Protocol.Message -> msg) -> NatsCmd.Cmd msg
request =
    NatsCmd.Request
