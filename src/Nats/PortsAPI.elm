module Nats.PortsAPI exposing
    ( Message, Ack, Ports
    , Open, Socket
    )

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


type alias Socket =
    { sid : String
    , url : String
    , mode : String
    , debug : Bool
    }


{-| This is the API that the ports module must implement.
-}
type alias Ports msg =
    { open : Socket -> Cmd msg
    , close : String -> Cmd msg
    , send : Message -> Cmd msg
    , onAck : (Ack -> msg) -> Sub msg
    , onOpen : (String -> msg) -> Sub msg
    , onClose : (String -> msg) -> Sub msg
    , onError : ({ sid : String, message : String } -> msg) -> Sub msg
    , onMessage : (Message -> msg) -> Sub msg
    }


type alias Open msg =
    Socket -> Cmd msg
