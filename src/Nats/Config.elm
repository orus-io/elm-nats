module Nats.Config exposing (bytes, string, withDebug)

{-| Define the configuration for NATS

@docs bytes, string, withDebug

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
string : (Msg msg -> msg) -> Ports (Msg msg) -> Config String msg
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

The parentMsg typically transform a Nats.Msg into the host application top-level
message.

    type Msg =
        NatsMsg (Nats.Msg Msg)
        | ...

    natsConfig =
        Nats.Config.init NatsMsg {}

-}
bytes : (Msg msg -> msg) -> Ports (Msg msg) -> Config Bytes msg
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


{-| Enable debug
-}
withDebug : Bool -> Config datatype msg -> Config datatype msg
withDebug value (Types.Config cfg) =
    Types.Config { cfg | debug = value }
