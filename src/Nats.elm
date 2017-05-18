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
        , map
        , batch
        , none
        , applyNatsCmd
        )

{-| This library provides a pure elm implementation of the NATS client
protocol on top of WebSocket.

The NATS server does not support websocket natively, so a NATS/websocket
proxy must be used. The only compatible one is
<https://github.com/orus-io/nats-websocket-gw>


# Types

@docs State, NatsCmd, Msg


# Operations

@docs publish, subscribe


# State handling

@docs init, update


# Subscriptions

@docs listen


# NatsCmd

@docs map, batch, none, applyNatsCmd

-}

import WebSocket
import Dict exposing (Dict)
import Time
import Nats.Protocol as Protocol


{-| Type of message the update function takes
-}
type Msg
    = Receive Protocol.Operation
    | ReceptionError String
    | KeepAlive Time.Time


{-| A Nats command
-}
type NatsCmd msg
    = Subscribe String (Protocol.Message -> msg)
    | QueueSubscribe String String (Protocol.Message -> msg)
    | Publish String String
    | Batch (List (NatsCmd msg))
    | None


{-| A NATS subscription
-}
type alias Subscription msg =
    { subject : String
    , queueGroup : String
    , sid : String
    , translate : Protocol.Message -> msg
    }


{-| The NATS state to add to the application model (once)
-}
type alias State msg =
    { url : String
    , keepAlive : Time.Time
    , sidCounter : Int
    , subscriptions : Dict String (Subscription msg)
    , serverInfo : Maybe Protocol.ServerInfo
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
            (Protocol.parseOperation >> receive state convert)
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
    }


send : State msg -> Protocol.Operation -> Cmd Msg
send state op =
    Protocol.toString op |> WebSocket.send state.url


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

        KeepAlive _ ->
            state ! [ send state Protocol.PING ]


initSubscription : String -> (Protocol.Message -> msg) -> Subscription msg
initSubscription subject translate =
    { subject = subject
    , queueGroup = ""
    , sid = ""
    , translate = translate
    }


initQueueSubscription : String -> String -> (Protocol.Message -> msg) -> Subscription msg
initQueueSubscription subject queueGroup translate =
    { subject = subject
    , queueGroup = queueGroup
    , sid = ""
    , translate = translate
    }


{-| subscribe to the given subject
-}
subscribe : String -> (Protocol.Message -> msg) -> NatsCmd msg
subscribe =
    Subscribe


{-| perform a queue subscribe to the given subject
-}
queueSubscribe : String -> String -> (Protocol.Message -> msg) -> NatsCmd msg
queueSubscribe =
    QueueSubscribe


{-| Apply NatsCmd in the Nats State and return somd actual Cmd
-}
applyNatsCmd : State msg -> NatsCmd msg -> ( State msg, Cmd Msg )
applyNatsCmd state cmd =
    case cmd of
        Subscribe subject translate ->
            setupSubscription state <| initSubscription subject translate

        QueueSubscribe subject queueGroup translate ->
            setupSubscription state <| initQueueSubscription subject queueGroup translate

        Publish subject data ->
            state
                ! [ send state <|
                        Protocol.PUB
                            { subject = subject
                            , replyTo = ""
                            , data = data
                            }
                  ]

        Batch natsCmds ->
            let
                folder natsCmd ( state, cmds ) =
                    let
                        ( newState, cmd ) =
                            applyNatsCmd state natsCmd
                    in
                        ( newState, cmd :: cmds )

                ( newState, cmds ) =
                    List.foldl folder ( state, [] ) natsCmds
            in
                newState ! cmds

        None ->
            state ! []


{-| Add a subscription to the State
-}
setupSubscription : State msg -> Subscription msg -> ( State msg, Cmd Msg )
setupSubscription state subscription =
    let
        sub : Subscription msg
        sub =
            { subscription
                | sid = toString state.sidCounter
            }
    in
        ( { state
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


{-| Transform the message produced by some Subscription
-}
map : (msg1 -> msg) -> NatsCmd msg1 -> NatsCmd msg
map msg1ToMsg cmd =
    case cmd of
        Subscribe subject translate ->
            Subscribe subject <| translate >> msg1ToMsg

        QueueSubscribe subject queueGroup translate ->
            QueueSubscribe subject queueGroup <| translate >> msg1ToMsg

        Publish subject data ->
            Publish subject data

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
