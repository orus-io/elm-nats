module Nats.Protocol exposing
    ( Operation(..), Message, ServerInfo, ConnectOptions, toString
    , OperationResult(..), PartialOperation
    , parseBytes, parseString, toBytes
    )

{-| Provides types and utilities for the NATS protocol

@docs Operation, Message, MessageData, ServerInfo, ConnectOptions, parseOperation, toString

@docs OperationResult, PartialOperation

-}

import Base64.Encode
import Bytes exposing (Bytes)
import Bytes.Decode
import Bytes.Encode
import Json.Decode as JsonD
import Json.Decode.Pipeline as JsonDP
import Json.Encode as JsonE
import Regex exposing (Regex)


{-| A NATS message
-}
type alias Message datatype =
    { subject : String
    , replyTo : String
    , size : Int
    , data : datatype
    }


type alias PartialMessage datatype =
    { subject : String
    , sid : String
    , replyTo : String
    , size : Int
    , data : datatype
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
    Operation datatype
    --| INFO 	Server 	Sent to client after initial TCP/IP connection
    = INFO ServerInfo
    | CONNECT ConnectOptions
    | PUB (Message datatype)
      -- SUB <subject> [queueGroup] <sid>
    | SUB String String String
      -- UNSUB <sid> [max_msgs]
    | UNSUB String Int
      -- MSG <sid> <message>
    | MSG String (Message datatype)
    | PING
    | PONG
    | OK
    | ERR String


messageRe : Maybe Regex
messageRe =
    Regex.fromString "^MSG ([a-zA-Z0-9._-]+) ([a-zA-Z0-9]+)( [a-zA-Z0-9._]+)? ([0-9]+)$"


parseCommandMessage :
    String
    ->
        Result
            String
            { subject : String
            , sid : String
            , replyTo : String
            , size : Int
            }
parseCommandMessage str =
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
            let
                args =
                    List.map (Maybe.withDefault "") match.submatches

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
            in
            case size |> String.toInt of
                Nothing ->
                    Err <| "Invalid size: " ++ size

                Just value ->
                    Result.Ok
                        { subject = subject
                        , sid = sid
                        , replyTo = replyTo
                        , size = value
                        }

        Nothing ->
            Result.Err <| "Invalid MSG syntax: " ++ str


{-| A temporary state when a parsing an operation is incomplete
-}
type PartialOperation datatype
    = PartialOperation (PartialMessage datatype)


{-| The result of parsing an operation
-}
type OperationResult datatype
    = Operation (Operation datatype)
    | Partial (PartialOperation datatype)
    | Error String


splitFirstLine : String -> ( String, String )
splitFirstLine s =
    case String.indexes cr s of
        [] ->
            ( s, "" )

        i :: _ ->
            ( String.left i s, String.dropLeft (i + 2) s )


parseCommand : datatype -> String -> Result String (Operation datatype)
parseCommand empty c =
    case c of
        "PING" ->
            Ok PING

        "PONG" ->
            Ok PONG

        "+OK" ->
            Ok OK

        _ ->
            if String.startsWith "INFO " c then
                case JsonD.decodeString decodeServerInfo <| String.dropLeft 5 c of
                    Ok info ->
                        Ok <| INFO info

                    Err err ->
                        Err <| JsonD.errorToString err

            else if String.startsWith "-ERR " c then
                Ok <| ERR <| String.dropRight 1 <| String.dropLeft 5 c

            else if String.startsWith "MSG" c then
                case parseCommandMessage c of
                    Result.Ok msg ->
                        Ok <|
                            MSG msg.sid
                                { subject = msg.subject
                                , replyTo = msg.replyTo
                                , size = msg.size
                                , data = empty
                                }

                    Result.Err err ->
                        Err err

            else
                Err <| "Invalid command '" ++ c ++ "'"


{-| Parse an operation (generally received from the server)
-}
parseString : String -> Maybe (PartialOperation String) -> OperationResult String
parseString str partialOp =
    case partialOp of
        Just (PartialOperation partial) ->
            let
                data =
                    String.append partial.data str

                newDataSize =
                    String.length data
            in
            if newDataSize == partial.size + 2 && String.endsWith cr data then
                Operation <|
                    MSG partial.sid <|
                        { subject = partial.subject
                        , replyTo = partial.replyTo
                        , size = partial.size
                        , data = String.dropRight 2 data
                        }

            else if newDataSize > partial.size + 2 then
                Error <| "Received too many data for the message"

            else
                Partial <|
                    PartialOperation
                        { partial | data = data }

        Nothing ->
            let
                ( firstLine, payload ) =
                    splitFirstLine str
            in
            case parseCommand "" firstLine of
                Err err ->
                    Error err

                Ok (MSG sid msg) ->
                    if String.length payload == msg.size + 2 && String.endsWith cr payload then
                        Operation <|
                            MSG sid
                                { subject = msg.subject
                                , replyTo = msg.replyTo
                                , size = msg.size
                                , data = String.dropRight 2 payload
                                }

                    else if String.length payload > msg.size + 2 then
                        Error <| "Too many data in the message payload"

                    else
                        Partial <|
                            PartialOperation
                                { sid = sid
                                , subject = msg.subject
                                , replyTo = msg.replyTo
                                , size = msg.size
                                , data = payload
                                }

                Ok op ->
                    Operation op


findStringInBytes : String -> Bytes -> Maybe Int
findStringInBytes s =
    let
        charList =
            String.toList s

        stringLen =
            String.length s

        step :
            ( List Char, Int )
            -> Bytes.Decode.Decoder (Bytes.Decode.Step ( List Char, Int ) (Maybe Int))
        step ( currentMatch, index ) =
            Bytes.Decode.string 1
                |> Bytes.Decode.map
                    (\chars ->
                        case ( String.toList chars, currentMatch ) of
                            ( [ next ], [ expected ] ) ->
                                if next == expected then
                                    index
                                        - stringLen
                                        + 1
                                        |> Just
                                        |> Bytes.Decode.Done

                                else
                                    Bytes.Decode.Loop ( charList, index + 1 )

                            ( [ next ], expected :: tail ) ->
                                if next == expected then
                                    Bytes.Decode.Loop ( tail, index + 1 )

                                else
                                    Bytes.Decode.Loop ( charList, index + 1 )

                            _ ->
                                Bytes.Decode.Done Nothing
                    )
    in
    Bytes.Decode.decode
        (Bytes.Decode.loop ( charList, 0 ) step)
        >> Maybe.andThen identity


parseBytes : Bytes -> Maybe (PartialOperation Bytes) -> OperationResult Bytes
parseBytes data partial =
    case partial of
        Just (PartialOperation msg) ->
            let
                body =
                    Bytes.Encode.sequence
                        [ Bytes.Encode.bytes msg.data
                        , Bytes.Encode.bytes data
                        ]
                        |> Bytes.Encode.encode

                bodyWidth =
                    Bytes.width body
            in
            if bodyWidth == msg.size + 2 then
                Operation <|
                    MSG msg.sid
                        { subject = msg.subject
                        , replyTo = msg.replyTo
                        , size = msg.size
                        , data = body
                        }

            else if bodyWidth > msg.size + 2 then
                Error "message payload is too big"

            else
                Partial <| PartialOperation <| { msg | data = body }

        Nothing ->
            case findStringInBytes cr data of
                Nothing ->
                    Error "Could not find CR separator"

                Just index ->
                    Bytes.Decode.decode
                        (Bytes.Decode.string index
                            |> Bytes.Decode.andThen
                                (\s ->
                                    case parseCommand emptyBytes s of
                                        Ok (MSG sid msg) ->
                                            let
                                                payloadWidth =
                                                    Bytes.width data - (index + 2)
                                            in
                                            if msg.size + 2 < payloadWidth then
                                                Bytes.Decode.fail

                                            else if msg.size + 2 == payloadWidth then
                                                Bytes.Decode.map2
                                                    (\_ payload ->
                                                        Operation <|
                                                            MSG sid { msg | data = payload }
                                                    )
                                                    (Bytes.Decode.bytes 2)
                                                    (Bytes.Decode.bytes msg.size)

                                            else
                                                Bytes.Decode.map2
                                                    (\_ payload ->
                                                        Partial <|
                                                            PartialOperation
                                                                { sid = sid
                                                                , subject = msg.subject
                                                                , replyTo = msg.replyTo
                                                                , size = msg.size
                                                                , data = payload
                                                                }
                                                    )
                                                    (Bytes.Decode.bytes 2)
                                                    (Bytes.Decode.bytes payloadWidth)

                                        Ok any ->
                                            Bytes.Decode.succeed <|
                                                Operation any

                                        Err err ->
                                            Bytes.Decode.succeed <|
                                                Error err
                                )
                        )
                        data
                        |> Maybe.withDefault (Error "could not decode input")


encodeConnect : ConnectOptions -> JsonE.Value
encodeConnect options =
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


opHeader : Operation datatype -> String
opHeader op =
    case op of
        INFO _ ->
            ""

        CONNECT options ->
            String.append "CONNECT " <|
                JsonE.encode 0 <|
                    encodeConnect options

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
                ++ String.fromInt message.size

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


{-| serialize to Bytes
-}
toBytes : Operation Bytes -> Bytes
toBytes op =
    [ opHeader op |> Bytes.Encode.string
    , crBytes |> Bytes.Encode.bytes
    ]
        ++ (case op of
                PUB message ->
                    [ message.data |> Bytes.Encode.bytes
                    , crBytes |> Bytes.Encode.bytes
                    ]

                _ ->
                    []
           )
        |> Bytes.Encode.sequence
        |> Bytes.Encode.encode


{-| serialize an Operation (generally for sending to the server)

if the operation contains data as bytes, the result string will be base64 encoded

-}
toString : Operation String -> String
toString op =
    opHeader op
        ++ cr
        ++ (case op of
                PUB message ->
                    message.data ++ cr

                _ ->
                    ""
           )


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


cr : String
cr =
    "\u{000D}\n"


stringBytes : String -> Bytes
stringBytes str =
    Bytes.Encode.string str
        |> Bytes.Encode.encode


emptyBytes : Bytes
emptyBytes =
    stringBytes ""


crBytes : Bytes
crBytes =
    stringBytes cr
