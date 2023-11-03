module Nats.Protocol exposing
    ( Operation(..), Message, ServerInfo, ConnectOptions
    , parseString, parseBytes, toBytes, toString
    , ParseResult, ParseState, initialParseState
    )

{-| Provides types and utilities for the NATS protocol

@docs Operation, Message, ServerInfo, ConnectOptions
@docs parseString, parseBytes, toBytes, toString

@docs ParseResult, ParseState, initialParseState

-}

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

Here is the protocol documentation:

    CONNECT Client Sent to server to specify connection information
    PUB Client Publish a message to a subject, with optional reply subject
    SUB Client Subscribe to a subject (or subject wildcard)
    UNSUB Client Unsubscribe (or auto-unsubscribe) from subject
    MSG Server Delivers a message payload to a subscriber
    PING Both PING keep-alive message
    PONG Both PONG keep-alive response
    +OK Server Acknowledges well-formed protocol message in verbose mode
    -ERR Server Indicates a protocol error. Will cause client disconnect.

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
        matches : List Regex.Match
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
                args : List String
                args =
                    List.map (Maybe.withDefault "") match.submatches

                size : String
                size =
                    List.drop 3 args
                        |> List.head
                        |> Maybe.withDefault ""
            in
            case size |> String.toInt of
                Nothing ->
                    Err <| "Invalid size: " ++ size

                Just value ->
                    let
                        subject : String
                        subject =
                            Maybe.withDefault "" (List.head args)

                        sid : String
                        sid =
                            Maybe.withDefault "" (List.drop 1 args |> List.head)

                        replyTo : String
                        replyTo =
                            case Maybe.withDefault "" (List.drop 2 args |> List.head) of
                                " " ->
                                    ""

                                v ->
                                    v
                    in
                    Result.Ok
                        { subject = subject
                        , sid = sid
                        , replyTo = replyTo
                        , size = value
                        }

        Nothing ->
            Result.Err <| "Invalid MSG syntax: " ++ str


{-| Returns a initial ParseState
-}
initialParseState : ParseState datatype
initialParseState =
    PartialCommand ""


{-| A temporary state when a parsing an operation is incomplete
-}
type ParseState datatype
    = PartialMessage
        { subject : String
        , sid : String
        , replyTo : String
        , size : Int
        , data : datatype
        }
    | PartialCommand String


{-| The result of parsing an operation
-}
type alias ParseResult datatype =
    Result String ( List (Operation datatype), ParseState datatype )


splitFirstLine : String -> ( String, Maybe String )
splitFirstLine s =
    case String.indexes cr s of
        [] ->
            ( s, Nothing )

        i :: _ ->
            ( String.left i s, Just <| String.dropLeft (i + 2) s )


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


{-| Parse an operation (generally received from the server) from a string

Any message contained will be of type 'String'

-}
parseString : ParseState String -> String -> ParseResult String
parseString partialOp str =
    case partialOp of
        PartialMessage partial ->
            let
                data : String
                data =
                    String.append partial.data str

                newDataSize : Int
                newDataSize =
                    String.length data
            in
            if newDataSize == partial.size + 2 && String.endsWith cr data then
                Ok
                    ( [ MSG partial.sid <|
                            { subject = partial.subject
                            , replyTo = partial.replyTo
                            , size = partial.size
                            , data = String.dropRight 2 data
                            }
                      ]
                    , initialParseState
                    )

            else if newDataSize > partial.size + 2 then
                case parseString initialParseState (String.dropLeft (partial.size + 2) data) of
                    Err err ->
                        Err err

                    Ok ( ops, nextPartial ) ->
                        Ok
                            ( MSG partial.sid
                                { subject = partial.subject
                                , replyTo = partial.replyTo
                                , size = partial.size
                                , data = String.left partial.size data
                                }
                                :: ops
                            , nextPartial
                            )

            else
                Ok ( [], PartialMessage { partial | data = data } )

        PartialCommand partial ->
            case
                splitFirstLine str
            of
                ( firstLine, Nothing ) ->
                    Ok ( [], PartialCommand <| partial ++ firstLine )

                ( firstLine, Just tail ) ->
                    case parseCommand "" (partial ++ firstLine) of
                        Err err ->
                            Err err

                        Ok (MSG sid msg) ->
                            if String.length tail == msg.size + 2 then
                                if String.endsWith cr tail then
                                    Ok
                                        ( [ MSG sid
                                                { subject = msg.subject
                                                , replyTo = msg.replyTo
                                                , size = msg.size
                                                , data = String.dropRight 2 tail
                                                }
                                          ]
                                        , initialParseState
                                        )

                                else
                                    Err "message payload size mismatch"

                            else if String.length tail > msg.size + 2 then
                                if String.dropLeft msg.size tail |> String.startsWith cr then
                                    case parseString initialParseState (String.dropLeft (msg.size + 2) tail) of
                                        Err err ->
                                            Err err

                                        Ok ( ops, nextPartial ) ->
                                            Ok
                                                ( MSG sid
                                                    { subject = msg.subject
                                                    , replyTo = msg.replyTo
                                                    , size = msg.size
                                                    , data = String.left msg.size tail
                                                    }
                                                    :: ops
                                                , nextPartial
                                                )

                                else
                                    Err "message payload size mismatch"

                            else
                                Ok
                                    ( []
                                    , PartialMessage
                                        { sid = sid
                                        , subject = msg.subject
                                        , replyTo = msg.replyTo
                                        , size = msg.size
                                        , data = tail
                                        }
                                    )

                        Ok op ->
                            case parseString initialParseState tail of
                                Err err ->
                                    Err err

                                Ok ( ops, nextPartial ) ->
                                    Ok
                                        ( op :: ops, nextPartial )


findStringInBytes : String -> Bytes -> Maybe Int
findStringInBytes s =
    let
        charList : List Char
        charList =
            String.toList s

        stringLen : Int
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


{-| Parse an operation from binary data.

Any message contained will be of type 'Bytes'

-}
parseBytes : ParseState Bytes -> Bytes -> ParseResult Bytes
parseBytes partialOp data =
    case partialOp of
        PartialCommand partial ->
            case findStringInBytes cr data of
                Nothing ->
                    case
                        data
                            |> Bytes.Decode.decode
                                (Bytes.Decode.string (Bytes.width data))
                    of
                        Just s ->
                            Ok
                                ( []
                                , PartialCommand <|
                                    partial
                                        ++ s
                                )

                        Nothing ->
                            Err "could not decode partial command"

                Just index ->
                    case
                        Bytes.Decode.decode
                            (Bytes.Decode.string index
                                |> Bytes.Decode.map (\s -> parseCommand emptyBytes (partial ++ s))
                            )
                            data
                    of
                        Nothing ->
                            Err "could not decode input"

                        Just (Err err) ->
                            Err err

                        Just (Ok cmd) ->
                            let
                                tail : Bytes
                                tail =
                                    bytesDropLeft (index + 2) data
                            in
                            case cmd of
                                MSG sid msg ->
                                    parseBytes
                                        (PartialMessage
                                            { sid = sid
                                            , subject = msg.subject
                                            , replyTo = msg.replyTo
                                            , size = msg.size
                                            , data = emptyBytes
                                            }
                                        )
                                        tail

                                any ->
                                    case parseBytes initialParseState tail of
                                        Ok ( ops, p ) ->
                                            Ok ( any :: ops, p )

                                        Err err ->
                                            Err err

        PartialMessage msg ->
            let
                body : Bytes
                body =
                    Bytes.Encode.sequence
                        [ Bytes.Encode.bytes msg.data
                        , Bytes.Encode.bytes data
                        ]
                        |> Bytes.Encode.encode

                bodyWidth : Int
                bodyWidth =
                    Bytes.width body
            in
            if bodyWidth == msg.size + 2 then
                Ok
                    ( [ MSG msg.sid
                            { subject = msg.subject
                            , replyTo = msg.replyTo
                            , size = msg.size

                            -- TODO make sure the 2 last bytes are a cr
                            , data = body |> bytesDropRight 2
                            }
                      ]
                    , initialParseState
                    )

            else if bodyWidth > msg.size + 2 then
                case parseBytes initialParseState <| bytesDropLeft (msg.size + 2) body of
                    Err err ->
                        Err err

                    Ok ( ops, partial ) ->
                        Ok
                            ( MSG msg.sid
                                { subject = msg.subject
                                , replyTo = msg.replyTo
                                , size = msg.size

                                -- TODO make sure the 2 last bytes are a cr
                                , data = body |> bytesLeft msg.size
                                }
                                :: ops
                            , partial
                            )

            else
                Ok ( [], PartialMessage { msg | data = body } )


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

        MSG _ _ ->
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


bytesDropLeft : Int -> Bytes -> Bytes
bytesDropLeft size data =
    let
        totalSize : Int
        totalSize =
            Bytes.width data

        firstSize : Int
        firstSize =
            if size < totalSize then
                size

            else
                totalSize
    in
    Bytes.Decode.decode
        (Bytes.Decode.map2 (\_ s -> s)
            (Bytes.Decode.bytes firstSize)
            (Bytes.Decode.bytes (totalSize - firstSize))
        )
        data
        |> Maybe.withDefault emptyBytes


bytesLeft : Int -> Bytes -> Bytes
bytesLeft size data =
    let
        totalSize : Int
        totalSize =
            Bytes.width data

        firstSize : Int
        firstSize =
            if size < totalSize then
                size

            else
                totalSize
    in
    Bytes.Decode.decode
        (Bytes.Decode.map2 (\s _ -> s)
            (Bytes.Decode.bytes firstSize)
            (Bytes.Decode.bytes (totalSize - firstSize))
        )
        data
        |> Maybe.withDefault emptyBytes


bytesDropRight : Int -> Bytes -> Bytes
bytesDropRight size data =
    let
        totalSize : Int
        totalSize =
            Bytes.width data

        secondSize : Int
        secondSize =
            if size < totalSize then
                size

            else
                totalSize
    in
    Bytes.Decode.decode
        (Bytes.Decode.map2 (\s _ -> s)
            (Bytes.Decode.bytes (totalSize - secondSize))
            (Bytes.Decode.bytes secondSize)
        )
        data
        |> Maybe.withDefault emptyBytes
