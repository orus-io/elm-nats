module Nats.Internal.Types exposing
    ( Effect(..)
    , Msg(..)
    , Socket(..)
    , SocketProps
    )

import Nats.Errors exposing (Timeout)
import Nats.Events exposing (SocketEvent)
import Nats.PortsAPI as PortsAPI
import Nats.Protocol as Protocol exposing (ConnectOptions, ServerInfo)
import Time


type alias SocketProps =
    { id : String
    , default : Bool
    , url : String
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
