module Nats.Events exposing (SocketEvent(..))

{-| Event types

@docs SocketEvent

-}

import Nats.Protocol exposing (ServerInfo)


{-| Event send during a socket lifecycle
-}
type SocketEvent
    = SocketOpen ServerInfo
    | SocketClose
    | SocketError String
