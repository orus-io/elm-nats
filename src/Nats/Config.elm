module Nats.Config exposing (Config, init, withDebug, withDebugLog)

import Nats.Internal.Types exposing (Msg)
import Nats.PortsAPI exposing (Ports)


type alias Config msg =
    { parentMsg : Msg msg -> msg
    , ports : Ports (Msg msg)
    , debug : Bool
    , debugLog : String -> String -> String
    }


init : (Msg msg -> msg) -> Ports (Msg msg) -> Config msg
init parentMsg ports =
    { parentMsg = parentMsg
    , ports = ports
    , debug = False
    , debugLog = \_ s -> s
    }


withDebug : Bool -> Config msg -> Config msg
withDebug value cfg =
    { cfg | debug = value }


withDebugLog : (String -> String -> String) -> Config msg -> Config msg
withDebugLog debugLog cfg =
    { cfg | debugLog = debugLog }
