port module NATSPorts exposing (ports)

import Nats


ports : Nats.Ports msg
ports =
    { connect = connect
    , socketOpened = socketOpened
    }


port connect : String -> String -> Cmd msg


port socketOpened : (String -> Nats.Msg msg) -> Sub (Nats.Msg msg)
