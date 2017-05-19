module Nats
    exposing
        ( State
        , NatsCmd
        , Msg
        , init
        , update
        , listen
        , publish
        , subscribe
        , request
        , map
        , batch
        , none
        , merge
        )

{-| This library provides a pure elm implementation of the NATS client
protocol on top of WebSocket.

The NATS server does not support websocket natively, so a NATS/websocket
proxy must be used. The only compatible one is
<https://github.com/orus-io/nats-websocket-gw>


# Types

@docs State, NatsCmd, Msg


# Operations

@docs publish, subscribe, request


# State handling

@docs init, update, merge


# Subscriptions

@docs listen


# NatsCmd

@docs map, batch, none

-}

import Debug
import WebSocket
import Dict exposing (Dict)
import Time
import Nats.Protocol as Protocol
import Random
import Random.Char
import Random.String
import Nats.Sub as NatsSub


{-| Type of message the update function takes
-}
type Msg
    = Receive Protocol.Operation
    | ReceptionError String
    | RequestInbox ( String, String ) String String
    | KeepAlive Time.Time


{-| A Nats command
-}
type NatsCmd msg
    = Publish String String
    | Request String String (Protocol.Message -> msg)
    | Batch (List (NatsCmd msg))
    | None


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
listen : State msg -> (Msg -> msg) -> Sub msg
listen state convert =
    Sub.batch
        [ WebSocket.listen
            state.url
            (Debug.log "Receiving" >> Protocol.parseOperation >> receive state convert)
        , Time.every state.keepAlive (KeepAlive >> convert)
        ]


{-| Initialize a Nats State for a given websocket URL
-}
init : String -> State msg
init url =
    { url = url
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


{-| The update function
Will make sure PING commands from the server are honored with a PONG,
and send a PING to keep the connection alive.
-}
update : Msg -> State msg -> ( State msg, Cmd Msg )
update msg state =
    case msg of
        Receive op ->
            case op of
                Protocol.PING ->
                    state ! [ send state Protocol.PONG ]

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
                            ! [ sendAll state
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

        KeepAlive _ ->
            state ! [ send state Protocol.PING ]


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


subscribe : String -> (Protocol.Message -> msg) -> NatsSub.Sub msg
subscribe subject tagger =
    NatsSub.Subscribe subject "" tagger


queuesubscribe : String -> String -> (Protocol.Message -> msg) -> NatsSub.Sub msg
queuesubscribe subject queueGroup tagger =
    NatsSub.Subscribe subject queueGroup tagger


tuple3last2 : ( a, b, c ) -> ( b, c )
tuple3last2 ( a, b, c ) =
    ( b, c )


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
mergeNatsCmd : State msg -> NatsCmd msg -> ( State msg, Cmd Msg )
mergeNatsCmd state cmd =
    case cmd of
        Publish subject data ->
            state
                ! [ send state <|
                        Protocol.PUB
                            { subject = subject
                            , replyTo = ""
                            , data = data
                            }
                  ]

        Request subject data translate ->
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

        Batch natsCmds ->
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

        None ->
            state ! []


merge : State msg -> NatsSub.Sub msg -> NatsCmd msg -> ( State msg, Cmd Msg )
merge state sub cmd =
    let
        ( subState, subCmd ) =
            mergeNatsSub state sub

        ( cmdState, cmdCmd ) =
            mergeNatsCmd subState cmd
    in
        ( cmdState, Cmd.batch [ subCmd, cmdCmd ] )


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
publish : String -> String -> NatsCmd msg
publish subject data =
    Publish subject data


{-| Send a request an return the response in a msg
-}
request : String -> String -> (Protocol.Message -> msg) -> NatsCmd msg
request =
    Request


{-| Transform the message produced by some Subscription
-}
map : (msg1 -> msg) -> NatsCmd msg1 -> NatsCmd msg
map msg1ToMsg cmd =
    case cmd of
        Publish subject data ->
            Publish subject data

        Request subject data translate ->
            Request subject data (translate >> msg1ToMsg)

        Batch natsCmds ->
            Batch <| List.map (map msg1ToMsg) natsCmds

        None ->
            None


{-| batch several NatsCmd into one
-}
batch : List (NatsCmd msg) -> NatsCmd msg
batch natsCmds =
    Batch natsCmds


{-| A NatsCmd that does nothing
-}
none : NatsCmd msg
none =
    None
