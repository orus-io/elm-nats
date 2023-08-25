module Nats.PortsAPI exposing (Message, Ports)

{-| Defines the API for the ports that are required to interface with JS.

@docs Message, Ports

-}


{-| This is the Message type that is send/received on some of the ports
-}
type alias Message =
    { sid : String
    , message : String
    }


{-| This is the API that the ports module must implement.
-}
type alias Ports msg =
    { open : ( String, String ) -> Cmd msg
    , close : String -> Cmd msg
    , send : Message -> Cmd msg
    , onOpen : (String -> msg) -> Sub msg
    , onClose : (String -> msg) -> Sub msg
    , onError : (Message -> msg) -> Sub msg
    , onMessage : (Message -> msg) -> Sub msg
    }
