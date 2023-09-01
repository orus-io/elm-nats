module Nats.Config exposing
    ( Config, withDebug, withDebugLog
    , bytes, string
    )

{-| Define the configuration for NATS

@docs Config, init, withDebug, withDebugLog

-}

import Base64.Decode
import Base64.Encode
import Bytes exposing (Bytes)
import Nats.Internal.Types exposing (Msg)
import Nats.PortsAPI exposing (Ports)
import Nats.Protocol as Protocol


{-| The NATS configuration
-}
type alias Config datatype msg =
    { parentMsg : Msg msg -> msg
    , ports : Ports (Msg msg)
    , debug : Bool
    , debugLog : String -> String -> String
    , size : datatype -> Int
    , parse : datatype -> Maybe (Protocol.PartialOperation datatype) -> Protocol.OperationResult datatype
    , write : Protocol.Operation datatype -> datatype
    , fromPortMessage : String -> Result String datatype
    , toPortMessage : datatype -> String
    }


{-| Create a NATS configuration

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
    { parentMsg = parentMsg
    , ports = ports
    , debug = False
    , debugLog = \_ s -> s
    , parse = Protocol.parseString
    , size = String.length
    , write = Protocol.toString
    , fromPortMessage = Ok
    , toPortMessage = identity
    }


{-| Create a NATS configuration

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
    { parentMsg = parentMsg
    , ports = ports
    , debug = False
    , debugLog = \_ s -> s
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
withDebug value cfg =
    { cfg | debug = value }


{-| Provide a debug log function
-}
withDebugLog : (String -> String -> String) -> Config datatype msg -> Config datatype msg
withDebugLog debugLog cfg =
    { cfg | debugLog = debugLog }
