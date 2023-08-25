module Nats.Protocol exposing
    ( Operation(..), Message, ServerInfo, ConnectOptions, parseOperation, toString
    , OperationResult(..), PartialOperation
    )

{-| Provides types and utilities for the NATS protocol

@docs Operation, Message, ServerInfo, ConnectOptions, parseOperation, toString

-}

import Json.Decode as JsonD
import Json.Decode.Pipeline as JsonDP
import Json.Encode as JsonE
import Regex exposing (Regex)


{-| A NATS message
-}
type alias Message =
    { subject : String
    , replyTo : String
    , data : String
    }


type alias PartialMessage =
    { subject : String
    , sid : String
    , replyTo : String
    , size : Int
    , data : String
    }


toMessage : PartialMessage -> Message
toMessage { subject, replyTo, data } =
    { subject = subject
    , replyTo = replyTo
    , data = data
    }


{-| Information sent by the server immediately after opening the connection
-}
type alias ServerInfo =
    { server_id : String -- The unique identifier of the NATS server
    , version : String -- The version of the NATS server
    , go : String -- The version of golang the NATS server was built with
    , host : String -- The IP address of the NATS server host
    , port_ : Int -- The port number the NATS server is configured to listen on
    , auth_required : Bool -- If this is set, then the client should try to authenticate upon connect.
    , max_payload : Int -- Maximum payload size that the server will accept from the client.
    }


{-| Options for the CONNECT operation
-}
type alias ConnectOptions =
    { verbose : Bool -- Turns on +OK protocol acknowledgements.
    , pedantic : Bool -- Turns on additional strict format checking, e.g. for properly formed subjects

    -- , ssl_required: Indicates whether the client requires an SSL connection.
    , auth_token : Maybe String -- Client authorization token
    , user : Maybe String -- Connection username (if auth_required is set)
    , pass : Maybe String -- Connection password (if auth_required is set)
    , name : Maybe String -- Optional client name
    , lang : String -- The implementation language of the client.
    , version : String -- The version of the client.
    , protocol : Int -- optional int. Sending 0 (or absent) indicates client supports original protocol. Sending 1 indicates that the client supports dynamic reconfiguration of cluster topology changes by asynchronously receiving INFO messages with known servers it can reconnect to.
    }


{-| Typed operations of the NATS protocol
-}



{-
   CONNECT Client  Sent to server to specify connection information
   PUB     Client  Publish a message to a subject, with optional reply subject
   SUB     Client  Subscribe to a subject (or subject wildcard)
   UNSUB   Client  Unsubscribe (or auto-unsubscribe) from subject
   MSG     Server  Delivers a message payload to a subscriber
   PING    Both    PING keep-alive message
   PONG    Both    PONG keep-alive response
   +OK     Server  Acknowledges well-formed protocol message in verbose mode
   -ERR    Server  Indicates a protocol error. Will cause client disconnect.
-}


type
    Operation
    --| INFO 	Server 	Sent to client after initial TCP/IP connection
    = INFO ServerInfo
    | CONNECT ConnectOptions
    | PUB Message
      -- SUB <subject> [queueGroup] <sid>
    | SUB String String String
      -- UNSUB <sid> [max_msgs]
    | UNSUB String Int
      -- MSG <sid> <message>
    | MSG String Message
    | PING
    | PONG
    | OK
    | ERR String


messageRe : Maybe Regex
messageRe =
    Regex.fromString "^MSG ([a-zA-Z0-9._-]+) ([a-zA-Z0-9]+)( [a-zA-Z0-9._]+)? ([0-9]+)\\r\\n(.*)$"


matchMessage : String -> Result String (List (Maybe String))
matchMessage str =
    let
        matches =
            case messageRe of
                Nothing ->
                    []

                Just re ->
                    Regex.findAtMost 1 re str
    in
    case List.head matches of
        Just match ->
            Result.Ok match.submatches

        Nothing ->
            Result.Err <| "Invalid MSG syntax: " ++ str


parseMessage : String -> Result String PartialMessage
parseMessage str =
    case matchMessage str of
        Ok subm ->
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

                size =
                    List.drop 3 args
                        |> List.head
                        |> Maybe.withDefault ""
                        |> String.toInt

                payload =
                    Maybe.withDefault "" (List.drop 4 args |> List.head)
            in
            case size of
                Nothing ->
                    Err "Invalid message size"

                Just s ->
                    Ok
                        { subject = subject
                        , sid = sid
                        , replyTo = replyTo
                        , size = s
                        , data = payload
                        }

        Err err ->
            Err err


isComplete : PartialMessage -> Bool
isComplete partial =
    String.length partial.data == partial.size


type alias PartialOperation =
    PartialMessage


type OperationResult
    = Operation Operation
    | Partial PartialOperation
    | Error String


{-| Parse an operation (generally received from the server)
-}
parseOperation : String -> Maybe PartialOperation -> OperationResult
parseOperation str partialOp =
    case partialOp of
        Just partial ->
            let
                msg =
                    { partial | data = String.append partial.data str }
            in
            if isComplete msg then
                Operation <| MSG partial.sid <| toMessage partial

            else
                Partial msg

        Nothing ->
            let
                stripped =
                    if String.endsWith "\u{000D}\n" str then
                        String.dropRight 2 str

                    else
                        str
            in
            case stripped of
                "PING" ->
                    Operation PING

                "PONG" ->
                    Operation PONG

                "+OK" ->
                    Operation OK

                _ ->
                    if String.startsWith "INFO " stripped then
                        case JsonD.decodeString decodeServerInfo <| String.dropLeft 5 stripped of
                            Ok info ->
                                Operation <| INFO info

                            Err err ->
                                Error <| JsonD.errorToString err

                    else if String.startsWith "-ERR " stripped then
                        Operation <| ERR <| String.dropRight 1 <| String.dropLeft 5 stripped

                    else if String.startsWith "MSG" stripped then
                        case parseMessage stripped of
                            Result.Ok partial ->
                                if isComplete partial then
                                    Operation <|
                                        MSG partial.sid
                                            { subject = partial.subject
                                            , replyTo = partial.replyTo
                                            , data = partial.data
                                            }

                                else
                                    Partial partial

                            Result.Err err ->
                                Error err

                    else
                        Error <| "Invalid command '" ++ stripped ++ "'"


{-| serialize an Operation (generally for sending to the server)
-}
toString : Operation -> String
toString op =
    (case op of
        INFO _ ->
            ""

        CONNECT options ->
            String.append "CONNECT " <|
                JsonE.encode 0 <|
                    JsonE.object <|
                        [ ( "verbose", JsonE.bool options.verbose )
                        , ( "pedantic", JsonE.bool options.pedantic )
                        , ( "lang", JsonE.string options.lang )
                        , ( "version", JsonE.string options.version )
                        , ( "protocol", JsonE.int options.protocol )
                        ]
                            ++ (case options.auth_token of
                                    Just auth_token ->
                                        [ ( "auth_token", JsonE.string auth_token ) ]

                                    Nothing ->
                                        []
                               )
                            ++ (case options.user of
                                    Just user ->
                                        [ ( "user", JsonE.string user ) ]

                                    Nothing ->
                                        []
                               )
                            ++ (case options.pass of
                                    Just pass ->
                                        [ ( "pass", JsonE.string pass ) ]

                                    Nothing ->
                                        []
                               )
                            ++ (case options.name of
                                    Just name ->
                                        [ ( "name", JsonE.string name ) ]

                                    Nothing ->
                                        []
                               )

        MSG sid message ->
            ""

        PING ->
            "PING"

        PONG ->
            "PONG"

        PUB message ->
            "PUB "
                ++ message.subject
                ++ (if not (String.isEmpty message.replyTo) then
                        " " ++ message.replyTo

                    else
                        ""
                   )
                ++ " "
                ++ String.fromInt (String.length message.data)
                ++ "\u{000D}\n"
                ++ message.data

        SUB subject queueGroup sid ->
            "SUB "
                ++ subject
                ++ " "
                ++ (if not (String.isEmpty queueGroup) then
                        queueGroup ++ " "

                    else
                        ""
                   )
                ++ sid

        UNSUB sid maxMsgs ->
            "UNSUB "
                ++ sid
                ++ (if maxMsgs /= 0 then
                        " " ++ String.fromInt maxMsgs

                    else
                        ""
                   )

        OK ->
            "OK"

        ERR err ->
            "ERR '" ++ err ++ "'"
    )
        ++ "\u{000D}\n"


decodeServerInfo : JsonD.Decoder ServerInfo
decodeServerInfo =
    JsonD.succeed ServerInfo
        |> JsonDP.required "server_id" JsonD.string
        |> JsonDP.required "version" JsonD.string
        |> JsonDP.required "go" JsonD.string
        |> JsonDP.required "host" JsonD.string
        |> JsonDP.required "port" JsonD.int
        |> JsonDP.optional "auth_required" JsonD.bool True
        |> JsonDP.required "max_payload" JsonD.int
