module Nats.Internal.Ports exposing
    ( Ack
    , Command
    , Event
    , Message
    , Socket
    , close
    , open
    , send
    )


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


type alias Command =
    { open : Maybe Socket
    , close : Maybe String
    , send : Maybe Message
    }


type alias Event =
    { ack : Maybe Ack
    , open : Maybe String
    , close : Maybe String
    , error : Maybe { sid : String, message : String }
    , message : Maybe Message
    }


open : Socket -> Command
open socket =
    { open = Just socket
    , close = Nothing
    , send = Nothing
    }


close : String -> Command
close sid =
    { open = Nothing
    , close = Just sid
    , send = Nothing
    }


send : Message -> Command
send msg =
    { open = Nothing
    , close = Nothing
    , send = Just msg
    }
