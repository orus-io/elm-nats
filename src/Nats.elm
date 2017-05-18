module Nats
    exposing
        ( State
        , Subscription
        , Msg
        , NatsMessage
        , init
        , update
        , listen
        , publish
        , subscribe
        , setupSubscription
        , setupSubscriptions
        )

{-| This library provides a pure elm implementation of the NATS client
protocol on top of WebSocket.

The NATS server does not support websocket natively, so a NATS/websocket
proxy must be used. The only compatible one is
<https://github.com/orus-io/nats-websocket-gw>

@docs State, Subscription , Msg , NatsMessage , init , update , listen , publish , subscribe, setupSubscription, setupSubscriptions

-}

import WebSocket
import Dict exposing (Dict)
import Time
import Regex exposing (Regex)


{-
   INFO 	Server 	Sent to client after initial TCP/IP connection
   CONNECT 	Client 	Sent to server to specify connection information
   PUB 	Client 	Publish a message to a subject, with optional reply subject
   SUB 	Client 	Subscribe to a subject (or subject wildcard)
   UNSUB 	Client 	Unsubscribe (or auto-unsubscribe) from subject
   MSG 	Server 	Delivers a message payload to a subscriber
   PING 	Both 	PING keep-alive message
   PONG 	Both 	PONG keep-alive response
   +OK 	Server 	Acknowledges well-formed protocol message in verbose mode
   -ERR 	Server 	Indicates a protocol error. Will cause client disconnect.
-}


{-| A message sent to or received from the nats server
-}
type alias NatsMessage =
    { subject : String
    , sid : String
    , replyTo : String
    , payload : String
    }


type Command
    = Message NatsMessage
    | Ping
    | Pong
    | Pub NatsMessage
    | Sub SubscriptionDef
    | Unsub String
    | AutoUnsub String Int
    | Ok
    | Err String


{-| Type of message the update function takes
-}
type Msg
    = Receive Command
    | KeepAlive Time.Time


{-| A NATS subscription
-}
type alias Subscription msg =
    { subject : String
    , queueGroup : String
    , sid : String
    , translate : NatsMessage -> msg
    }


type alias SubscriptionDef =
    { subject : String
    , queueGroup : String
    , sid : String
    }


{-| The NATS state to add to the application model (once)
-}
type alias State msg =
    { url : String
    , keepAlive : Time.Time
    , sidCounter : Int
    , subscriptions : Dict String (Subscription msg)
    }


natsMessageRe : Regex
natsMessageRe =
    Regex.regex "^MSG ([a-zA-Z0-9.]+) ([a-zA-Z0-9]+)( [a-zA-Z0-9.]+)? [0-9]+\\r\\n(.*)\\r\\n$"


matchNatsMessage : String -> Result String (List (Maybe String))
matchNatsMessage str =
    let
        matches =
            Regex.find (Regex.AtMost 1) natsMessageRe str
    in
        case List.head matches of
            Just match ->
                Result.Ok match.submatches

            Nothing ->
                Result.Err "Invalid MSG syntax"


parseNatsMessage : String -> Result String NatsMessage
parseNatsMessage str =
    case matchNatsMessage str of
        Result.Ok subm ->
            let
                args =
                    List.map (Maybe.withDefault "") subm

                subject =
                    Maybe.withDefault "" (List.head args)

                sid =
                    Maybe.withDefault "" (List.drop 1 args |> List.head)

                replyTo =
                    case Maybe.withDefault "" (List.drop 2 args |> List.head) of
                        " " ->
                            ""

                        v ->
                            v

                payload =
                    Maybe.withDefault "" (List.drop 3 args |> List.head)
            in
                Result.Ok <|
                    { subject = subject
                    , sid = sid
                    , replyTo = replyTo
                    , payload = payload
                    }

        Result.Err err ->
            Result.Err err


parseCommand : String -> Command
parseCommand str =
    case str of
        "PING\x0D\n" ->
            Ping

        "PONG\x0D\n" ->
            Pong

        "+OK\x0D\n" ->
            Ok

        _ ->
            if String.startsWith "-ERR" str then
                Err <| String.dropLeft 4 str
            else if String.startsWith "MSG" str then
                case parseNatsMessage str of
                    Result.Ok message ->
                        Message message

                    Result.Err err ->
                        Err err
            else
                Err <| "Invalid command '" ++ str ++ "'"


receive : State msg -> (Msg -> msg) -> Command -> msg
receive state convert command =
    case command of
        Message natsMsg ->
            case Dict.get natsMsg.sid state.subscriptions of
                Just sub ->
                    sub.translate natsMsg

                Nothing ->
                    convert <| Receive command

        _ ->
            convert <| Receive command


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
            (parseCommand >> receive state convert)
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


cmdToString : Command -> String
cmdToString cmd =
    (case cmd of
        Message message ->
            ""

        Ping ->
            "PING"

        Pong ->
            "PONG"

        Pub natsMsg ->
            "PUB "
                ++ natsMsg.subject
                ++ (if not (String.isEmpty natsMsg.replyTo) then
                        " " ++ natsMsg.replyTo
                    else
                        ""
                   )
                ++ " "
                ++ toString (String.length natsMsg.payload)
                ++ "\x0D\n"
                ++ natsMsg.payload

        Sub sub ->
            "SUB "
                ++ sub.subject
                ++ " "
                ++ (if not (String.isEmpty sub.queueGroup) then
                        sub.queueGroup ++ " "
                    else
                        ""
                   )
                ++ sub.sid

        Unsub sid ->
            "UNSUB " ++ sid

        AutoUnsub sid maxMsgs ->
            "UNSUB " ++ sid ++ " " ++ toString maxMsgs

        Ok ->
            "OK"

        Err err ->
            "ERR " ++ err
    )
        ++ "\x0D\n"


send : State msg -> Command -> Cmd Msg
send state cmd =
    cmdToString cmd |> WebSocket.send state.url


{-| The update function
Will make sure PING commands from the server are honored with a PONG,
and send a PING to keep the connection alive.
-}
update : Msg -> State msg -> ( State msg, Cmd Msg )
update msg state =
    case msg of
        Receive command ->
            case command of
                Ping ->
                    state ! [ send state Pong ]

                _ ->
                    state ! []

        KeepAlive _ ->
            state ! [ send state Ping ]


initSubscription : String -> (NatsMessage -> msg) -> Subscription msg
initSubscription subject translate =
    { subject = subject
    , queueGroup = ""
    , sid = ""
    , translate = translate
    }


initQueueSubscription : String -> String -> String -> (NatsMessage -> msg) -> Subscription msg
initQueueSubscription subject queueGroup sid translate =
    { subject = subject
    , queueGroup = queueGroup
    , sid = sid
    , translate = translate
    }


subscriptionDef : Subscription msg -> SubscriptionDef
subscriptionDef sub =
    { subject = sub.subject
    , queueGroup = sub.queueGroup
    , sid = sub.sid
    }


{-| Initialize a Subscription for the given subject
It takes the State and returns it modified.
-}
subscribe : String -> (NatsMessage -> msg) -> Subscription msg
subscribe subject translate =
    { subject = subject
    , queueGroup = ""
    , sid = ""
    , translate = translate
    }


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
        , send state <| Sub <| subscriptionDef sub
        )


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
publish state subject payload =
    send state <|
        Pub
            { subject = subject
            , sid = ""
            , replyTo = ""
            , payload = payload
            }
