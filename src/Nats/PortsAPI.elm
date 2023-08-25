module Nats.PortsAPI exposing (Message, Ports)


type alias Message =
    { sid : String
    , message : String
    }


type alias Ports msg =
    { open : ( String, String ) -> Cmd msg
    , close : String -> Cmd msg
    , send : Message -> Cmd msg
    , onOpen : (String -> msg) -> Sub msg
    , onClose : (String -> msg) -> Sub msg
    , onError : (Message -> msg) -> Sub msg
    , onMessage : (Message -> msg) -> Sub msg
    }
