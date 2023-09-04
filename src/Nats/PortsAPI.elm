module Nats.PortsAPI exposing
    ( Message, Ack, Socket, Ports
    , Open, Close, Send, OnAck, OnOpen, OnClose, OnError, OnMessage
    )

{-| Defines the API for the ports that are required to interface with JS.

@docs Message, Ack, Socket, Ports

@docs Open, Close, Send, OnAck, OnOpen, OnClose, OnError, OnMessage

-}


{-| This is the Message type that is send/received on some of the ports
-}
type alias Message =
    { sid : String
    , ack : Maybe String
    , message : String
    }


{-| Acknowlegments. Sent by the js side after it has done some task
-}
type alias Ack =
    { sid : String
    , ack : String
    }


{-| All the data needed by the js side to open a socket
-}
type alias Socket =
    { sid : String
    , url : String
    , mode : String
    , debug : Bool
    }


{-| This is the API that the ports module must implement.
-}
type alias Ports msg =
    { open : Open msg
    , close : Close msg
    , send : Send msg
    , onAck : OnAck msg
    , onOpen : OnOpen msg
    , onClose : OnClose msg
    , onError : OnError msg
    , onMessage : OnMessage msg
    }


{-| The 'open' port signature
-}
type alias Open msg =
    Socket -> Cmd msg


{-| The 'close' port signature
-}
type alias Close msg =
    String -> Cmd msg


{-| The 'send' port signature
-}
type alias Send msg =
    Message -> Cmd msg


{-| The 'onAck' port signature
-}
type alias OnAck msg =
    (Ack -> msg) -> Sub msg


{-| The 'onOpen' port signature
-}
type alias OnOpen msg =
    (String -> msg) -> Sub msg


{-| The 'onClose' port signature
-}
type alias OnClose msg =
    (String -> msg) -> Sub msg


{-| The 'onError' port signature
-}
type alias OnError msg =
    ({ sid : String, message : String } -> msg) -> Sub msg


{-| The 'onMessage' port signature
-}
type alias OnMessage msg =
    (Message -> msg) -> Sub msg
