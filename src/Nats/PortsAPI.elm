module Nats.PortsAPI exposing
    ( Ports
    , Command, Event, Send, Receive
    )

{-| Defines the API for the ports that are required to interface with JS.

@docs Ports

@docs Command, Event, Send, Receive

-}

import Nats.Internal.Ports as Ports


{-| A command for the js side
-}
type alias Command datatype =
    Ports.Command datatype


{-| An event from the js side
-}
type alias Event datatype =
    Ports.Event datatype


{-| the port signature for sending commands to the js side
-}
type alias Send datatype msg =
    Command datatype -> Cmd msg


{-| the port signature for receiving events from the js side
-}
type alias Receive datatype msg =
    (Event datatype -> msg) -> Sub msg


{-| This is the API that the ports module must implement.
-}
type alias Ports datatype msg =
    { send : Send datatype msg
    , receive : Receive datatype msg
    }
