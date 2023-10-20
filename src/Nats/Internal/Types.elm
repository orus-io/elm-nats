module Nats.Internal.Types exposing
    ( Config(..)
    , Effect(..)
    , Msg(..)
    , Socket(..)
    , SocketProps
    )

import Nats.Errors exposing (Timeout)
import Nats.Internal.Ports as Ports
import Nats.PortsAPI as PortsAPI
import Nats.Protocol as Protocol
import Time


type Config datatype portdatatype msg
    = Config
        { parentMsg : Msg datatype msg -> msg
        , ports : PortsAPI.Ports portdatatype (Msg datatype msg)
        , debug : Bool
        , onError : Maybe (String -> msg)
        , size : datatype -> Int
        , mode : String
        , parse : Protocol.ParseState datatype -> datatype -> Protocol.ParseResult datatype
        , write : Protocol.Operation datatype -> datatype
        , fromPortMessage : portdatatype -> Result String datatype
        , toPortMessage : datatype -> portdatatype
        }


type alias SocketProps =
    { id : String
    , default : Bool
    , url : String
    , debug : Bool
    }


type Socket
    = Socket SocketProps


type Msg datatype msg
    = OnAck Ports.Ack
    | OnOpen String
    | OnClose String
    | OnError { sid : String, message : String }
    | OnMessage (Ports.Message datatype)
    | OnTime Time.Posix


type Effect datatype msg
    = Pub { sid : Maybe String, subject : String, replyTo : Maybe String, message : datatype }
    | Request
        { sid : Maybe String
        , marker : Maybe String
        , subject : String
        , message : datatype
        , timeout : Maybe Int
        , onTimeout : Timeout -> msg
        , onResponse : Protocol.Message datatype -> ( Maybe msg, Bool )
        }
    | CancelRequest { sid : Maybe String, marker : String }
    | NoEffect
    | BatchEffect (List (Effect datatype msg))
