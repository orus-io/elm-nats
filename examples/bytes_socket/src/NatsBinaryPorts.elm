port module NatsBinaryPorts exposing (natsConfig)

import Bytes exposing (Bytes)
import Nats
import Nats.Config
import Nats.PortsAPI



---- PORTS ----


type alias NatsPortDataType =
    Bytes


port natsSend : Nats.PortsAPI.Send NatsPortDataType msg


port natsReceive : Nats.PortsAPI.Receive NatsPortDataType msg


natsConfig : (Nats.Msg Bytes msg -> msg) -> Nats.Config Bytes NatsPortDataType msg
natsConfig toMsg =
    Nats.Config.bytesPorts toMsg
        { send = natsSend
        , receive = natsReceive
        }
        |> Nats.Config.withDebug False
