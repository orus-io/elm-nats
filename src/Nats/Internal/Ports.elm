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


type alias Message datatype =
    { sid : String
    , ack : Maybe String
    , message : datatype
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


type alias Command datatype =
    { open : Maybe Socket
    , close : Maybe String
    , send : Maybe (Message datatype)
    }


type alias Event datatype =
    { ack : Maybe Ack
    , open : Maybe String
    , close : Maybe String
    , error : Maybe { sid : String, message : String }
    , message : Maybe (Message datatype)
    }


open : Socket -> Command datatype
open socket =
    { open = Just socket
    , close = Nothing
    , send = Nothing
    }


close : String -> Command datatype
close sid =
    { open = Nothing
    , close = Just sid
    , send = Nothing
    }


send : Message datatype -> Command datatype
send msg =
    { open = Nothing
    , close = Nothing
    , send = Just msg
    }
