module Nats.Internal.Types exposing
    ( Config(..)
    , Effect(..)
    , Msg(..)
    , Socket(..)
    , SocketProps
    )

import Nats.Errors exposing (Timeout)
import Nats.PortsAPI as PortsAPI
import Nats.Protocol as Protocol
import Time


type Config datatype msg
    = Config
        { parentMsg : Msg msg -> msg
        , ports : PortsAPI.Ports (Msg msg)
        , debug : Bool
        , onError : Maybe (String -> msg)
        , size : datatype -> Int
        , mode : String
        , parse : datatype -> Maybe (Protocol.PartialOperation datatype) -> Protocol.OperationResult datatype
        , write : Protocol.Operation datatype -> datatype
        , fromPortMessage : String -> Result String datatype
        , toPortMessage : datatype -> String
        }


type alias SocketProps =
    { id : String
    , default : Bool
    , url : String
    , debug : Bool
    }


type Socket
    = Socket SocketProps


type Msg msg
    = OnOpen String
    | OnClose String
    | OnError { sid : String, message : String }
    | OnMessage PortsAPI.Message
    | OnAck PortsAPI.Ack
    | OnTime Time.Posix


type Effect datatype msg
    = Pub { sid : Maybe String, subject : String, replyTo : Maybe String, message : datatype }
    | Request { sid : Maybe String, subject : String, group : String, message : datatype, timeout : Maybe Int, onResponse : Result Timeout datatype -> msg }
    | NoEffect
    | BatchEffect (List (Effect datatype msg))
