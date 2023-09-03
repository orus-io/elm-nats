module Nats.PortsAPI exposing (Message, Ack, Ports)

{-| Defines the API for the ports that are required to interface with JS.

@docs Message, Ack, Ports

-}


{-| This is the Message type that is send/received on some of the ports
-}
type alias Message =
    { sid : String
    , ack : Maybe String
    , message : String
    }


type alias Ack =
    { sid : String
    , ack : String
    }


{-| This is the API that the ports module must implement.
-}
type alias Ports msg =
    { open : ( String, String, String ) -> Cmd msg
    , close : String -> Cmd msg
    , send : Message -> Cmd msg
    , onAck : (Ack -> msg) -> Sub msg
    , onOpen : (String -> msg) -> Sub msg
    , onClose : (String -> msg) -> Sub msg
    , onError : ({ sid : String, message : String } -> msg) -> Sub msg
    , onMessage : (Message -> msg) -> Sub msg
    }
