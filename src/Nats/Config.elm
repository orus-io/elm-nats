module Nats.Config exposing (Config, init, withDebug, withDebugLog)

{-| Define the configuration for NATS

@docs Config, init, withDebug, withDebugLog

-}

import Nats.Internal.Types exposing (Msg)
import Nats.PortsAPI exposing (Ports)


{-| The NATS configuration
-}
type alias Config msg =
    { parentMsg : Msg msg -> msg
    , ports : Ports (Msg msg)
    , debug : Bool
    , debugLog : String -> String -> String
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
init : (Msg msg -> msg) -> Ports (Msg msg) -> Config msg
init parentMsg ports =
    { parentMsg = parentMsg
    , ports = ports
    , debug = False
    , debugLog = \_ s -> s
    }


{-| Enable debug
-}
withDebug : Bool -> Config msg -> Config msg
withDebug value cfg =
    { cfg | debug = value }


{-| Provide a debug log function
-}
withDebugLog : (String -> String -> String) -> Config msg -> Config msg
withDebugLog debugLog cfg =
    { cfg | debugLog = debugLog }
