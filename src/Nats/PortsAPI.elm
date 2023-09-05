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
type alias Command =
    Ports.Command


{-| An event from the js side
-}
type alias Event =
    Ports.Event


{-| the port signature for sending commands to the js side
-}
type alias Send msg =
    Command -> Cmd msg


{-| the port signature for receiving events from the js side
-}
type alias Receive msg =
    (Event -> msg) -> Sub msg


{-| This is the API that the ports module must implement.
-}
type alias Ports msg =
    { send : Send msg
    , receive : Receive msg
    }
