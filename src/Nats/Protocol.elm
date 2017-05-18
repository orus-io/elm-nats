module Nats.Protocol
    exposing
        ( Operation(..)
        , Message
        , ServerInfo
        , ConnectOptions
        , parseOperation
        , toString
        )

{-| Provides types and utilities for the NATS protocol

@docs Operation , Message, ServerInfo, ConnectOptions, parseOperation, toString

-}

import Regex exposing (Regex)


{-| A NATS message
-}
type alias Message =
    { subject : String
    , replyTo : String
    , data : String
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
    , max_payload : Bool -- Maximum payload size that the server will accept from the client.
    }


{-| Options for the CONNECT operation
-}
type alias ConnectOptions =
    { verbose : Bool -- Turns on +OK protocol acknowledgements.
    , pedantic : Bool -- Turns on additional strict format checking, e.g. for properly formed subjects

    -- , ssl_required: Indicates whether the client requires an SSL connection.
    , auth_token : String -- Client authorization token
    , user : String -- Connection username (if auth_required is set)
    , pass : String -- Connection password (if auth_required is set)
    , name : String -- Optional client name
    , lang : String -- The implementation language of the client.
    , version : String -- The version of the client.
    , protocol : Int -- optional int. Sending 0 (or absent) indicates client supports original protocol. Sending 1 indicates that the client supports dynamic reconfiguration of cluster topology changes by asynchronously receiving INFO messages with known servers it can reconnect to.
    }


{-| Typed operations of the NATS protocol
-}



{-
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


messageRe : Regex
messageRe =
    Regex.regex "^MSG ([a-zA-Z0-9.]+) ([a-zA-Z0-9]+)( [a-zA-Z0-9.]+)? [0-9]+\\r\\n(.*)\\r\\n$"


matchMessage : String -> Result String (List (Maybe String))
matchMessage str =
    let
        matches =
            Regex.find (Regex.AtMost 1) messageRe str
    in
        case List.head matches of
            Just match ->
                Result.Ok match.submatches

            Nothing ->
                Result.Err "Invalid MSG syntax"


parseMessage : String -> Result String ( String, Message )
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

                payload =
                    Maybe.withDefault "" (List.drop 3 args |> List.head)
            in
                Ok
                    ( sid
                    , { subject = subject
                      , replyTo = replyTo
                      , data = payload
                      }
                    )

        Err err ->
            Err err


{-| Parse an operation (generally received from the server)
-}
parseOperation : String -> Result String Operation
parseOperation str =
    let
        stripped =
            if String.endsWith "\x0D\n" str then
                String.dropRight 2 str
            else
                str
    in
        case stripped of
            "PING\x0D\n" ->
                Ok PING

            "PONG\x0D\n" ->
                Ok PONG

            "+OK\x0D\n" ->
                Ok OK

            _ ->
                if String.startsWith "-ERR" str then
                    Ok <| ERR <| String.dropRight 1 <| String.dropLeft 5 str
                else if String.startsWith "MSG" str then
                    case parseMessage str of
                        Result.Ok ( sid, message ) ->
                            Ok <| MSG sid message

                        Result.Err err ->
                            Err err
                else
                    Err <| "Invalid command '" ++ str ++ "'"


{-| serialize an Operation (generally for sending to the server)
-}
toString : Operation -> String
toString op =
    (case op of
        INFO _ ->
            ""

        CONNECT _ ->
            ""

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
                ++ Basics.toString (String.length message.data)
                ++ "\x0D\n"
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
                ++ if maxMsgs /= 0 then
                    " " ++ Basics.toString maxMsgs
                   else
                    ""

        OK ->
            "OK"

        ERR err ->
            "ERR '" ++ err ++ "'"
    )
        ++ "\x0D\n"
