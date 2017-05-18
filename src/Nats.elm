module Nats
    exposing
        ( State
        , Subscription
        , Msg
        , init
        , update
        , listen
        , publish
        , subscribe
        , map
        , mapAll
        , setupSubscription
        , setupSubscriptions
        )

{-| This library provides a pure elm implementation of the NATS client
protocol on top of WebSocket.

The NATS server does not support websocket natively, so a NATS/websocket
proxy must be used. The only compatible one is
<https://github.com/orus-io/nats-websocket-gw>

@docs State, Subscription , Msg , init , update , listen , publish , subscribe, setupSubscription, setupSubscriptions, map, mapAll

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


initQueueSubscription : String -> String -> String -> (Protocol.Message -> msg) -> Subscription msg
initQueueSubscription subject queueGroup sid translate =
    { subject = subject
    , queueGroup = queueGroup
    , sid = sid
    , translate = translate
    }


{-| Initialize a Subscription for the given subject
It takes the State and returns it modified.
-}
subscribe : String -> (Protocol.Message -> msg) -> Subscription msg
subscribe subject translate =
    { subject = subject
    , queueGroup = ""
    , sid = ""
    , translate = translate
    }


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


{-| Add subscriptions to the State
-}
setupSubscriptions : State msg -> List (Subscription msg) -> ( State msg, Cmd Msg )
setupSubscriptions state subscriptions =
    let
        folder subscription ( state, cmds ) =
            let
                ( newState, cmd ) =
                    setupSubscription state subscription
            in
                ( newState, cmd :: cmds )

        ( newState, cmds ) =
            List.foldl folder ( state, [] ) subscriptions
    in
        newState ! cmds


{-| Publish a message on a subject
-}
publish : State msg -> String -> String -> Cmd Msg
publish state subject data =
    send state <|
        Protocol.PUB
            { subject = subject
            , replyTo = ""
            , data = data
            }


{-| Transform the message produced by some Subscription
-}
map : (msg1 -> msg) -> Subscription msg1 -> Subscription msg
map translate sub =
    { sub
        | translate = sub.translate >> translate
    }


{-| Transform the message produced by some Subscription
-}
mapAll : (msg1 -> msg) -> List (Subscription msg1) -> List (Subscription msg)
mapAll translate subs =
    List.map (map translate) subs
