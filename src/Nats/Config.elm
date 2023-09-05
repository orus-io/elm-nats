module Nats.Config exposing (bytes, bytesPorts, string, withDebug)

{-| Define the configuration for NATS

@docs bytes, bytesPorts, string, withDebug

-}

import Base64.Decode
import Base64.Encode
import Bytes exposing (Bytes)
import Nats exposing (Config, Msg)
import Nats.Internal.Types as Types
import Nats.PortsAPI exposing (Ports)
import Nats.Protocol as Protocol


{-| Create a NATS configuration for string messages

The parentMsg typically transform a Nats.Msg into the host application top-level
message.

    type Msg =
        NatsMsg (Nats.Msg Msg)
        | ...

    natsConfig =
        Nats.Config.init NatsMsg {}

-}
string : (Msg String msg -> msg) -> Ports String (Msg String msg) -> Config String String msg
string parentMsg ports =
    Types.Config
        { parentMsg = parentMsg
        , ports = ports
        , debug = False
        , onError = Nothing
        , mode = "text"
        , parse = Protocol.parseString
        , size = String.length
        , write = Protocol.toString
        , fromPortMessage = Ok
        , toPortMessage = identity
        }


{-| Create a NATS configuration for bytes messages

The binary contents will be base64 encoded/decoded for passing through the ports

-}
bytes : (Msg Bytes msg -> msg) -> Ports String (Msg Bytes msg) -> Config Bytes String msg
bytes parentMsg ports =
    Types.Config
        { parentMsg = parentMsg
        , ports = ports
        , debug = False
        , onError = Nothing
        , mode = "binary"
        , parse = Protocol.parseBytes
        , size = Bytes.width
        , write = Protocol.toBytes
        , fromPortMessage =
            Base64.Decode.decode Base64.Decode.bytes
                >> Result.mapError
                    (\e ->
                        case e of
                            Base64.Decode.ValidationError ->
                                "Base64 validation error"

                            Base64.Decode.InvalidByteSequence ->
                                "Base64 invalid base sequence"
                    )
        , toPortMessage = Base64.Encode.bytes >> Base64.Encode.encode
        }


{-| Create a NATS configuration for bytes messages through ports supporting
the Bytes type.

The binary contents will be passed as is through the ports.
Currently the only known compiler supporting this is the Lamdera compiler, which
requires the dependency "lamdera/codecs" to be added to your project.

-}
bytesPorts : (Msg Bytes msg -> msg) -> Ports Bytes (Msg Bytes msg) -> Config Bytes Bytes msg
bytesPorts parentMsg ports =
    Types.Config
        { parentMsg = parentMsg
        , ports = ports
        , debug = False
        , onError = Nothing
        , mode = "binaryPort"
        , parse = Protocol.parseBytes
        , size = Bytes.width
        , write = Protocol.toBytes
        , fromPortMessage = Ok
        , toPortMessage = identity
        }


{-| Enable debug
-}
withDebug : Bool -> Config datatype portdatatype msg -> Config datatype portdatatype msg
withDebug value (Types.Config cfg) =
    Types.Config { cfg | debug = value }
