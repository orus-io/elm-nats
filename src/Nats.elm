module Nats exposing (..)

{-| @docs init
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
    | Sub SubscriptionState
    | Unsub String
    | AutoUnsub String Int
    | Ok
    | Err String


type Msg
    = Receive Command
    | KeepAlive Time.Time


type Subscription msg
    = Subscription (NatsMessage -> msg) String


type alias SubscriptionState =
    { subject : String
    , queueGroup : String
    , sid : String
    }


type alias State =
    { url : String
    , keepAlive : Time.Time
    , sidCounter : Int
    , subscriptions : Dict String SubscriptionState
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


receive : State -> (Msg -> msg) -> Dict String (NatsMessage -> msg) -> Command -> msg
receive state convert subscriptions command =
    case command of
        Message natsMsg ->
            case Dict.get natsMsg.sid subscriptions of
                Just translate ->
                    translate natsMsg

                Nothing ->
                    convert <| Receive command

        _ ->
            convert <| Receive command


listen : State -> (Msg -> msg) -> List (Subscription msg) -> Sub msg
listen state convert subscriptions =
    let
        subscriptionsDict =
            List.map
                (\sub ->
                    (case sub of
                        Subscription translate sid ->
                            ( sid, translate )
                    )
                )
                subscriptions
                |> Dict.fromList
    in
        Sub.batch
            [ WebSocket.listen
                state.url
                (parseCommand >> receive state convert subscriptionsDict)
            , Time.every state.keepAlive (KeepAlive >> convert)
            ]


init : String -> State
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


send : State -> Command -> Cmd Msg
send state cmd =
    cmdToString cmd |> WebSocket.send state.url


update : Msg -> State -> ( State, Cmd Msg )
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


initSubscription : String -> String -> SubscriptionState
initSubscription subject sid =
    { subject = subject
    , queueGroup = ""
    , sid = sid
    }


initQueueSubscription : String -> String -> String -> SubscriptionState
initQueueSubscription subject queueGroup sid =
    { subject = subject
    , queueGroup = queueGroup
    , sid = sid
    }


subscribe : State -> String -> (NatsMessage -> msg) -> ( Subscription msg, State, Cmd Msg )
subscribe state subject translate =
    let
        subState =
            initSubscription subject (toString state.sidCounter)
    in
        ( Subscription translate (toString state.sidCounter)
        , { state
            | sidCounter = state.sidCounter + 1
            , subscriptions =
                Dict.insert (toString state.sidCounter) subState state.subscriptions
          }
        , send state <| Sub subState
        )


publish : State -> String -> String -> Cmd Msg
publish state subject payload =
    send state <|
        Pub
            { subject = subject
            , sid = ""
            , replyTo = ""
            , payload = payload
            }
