module Nats.Events exposing (SocketEvent(..))

import Nats.Protocol exposing (ServerInfo)


type SocketEvent
    = SocketOpen ServerInfo
    | SocketClose
    | SocketError String
