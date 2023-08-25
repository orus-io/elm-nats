module Nats.Internal.Types exposing
    ( Effect(..)
    , Msg(..)
    , Socket(..)
    , SocketProps
    , Sub(..)
    , mapSocket
    )

import Nats.Errors exposing (Timeout)
import Nats.PortsAPI as PortsAPI
import Nats.Protocol as Protocol exposing (ConnectOptions, ServerInfo)
import Time


type alias SocketProps msg =
    { id : String
    , default : Bool
    , url : String
    , connectOptions : ConnectOptions
    , onOpen : Maybe (ServerInfo -> msg)
    , onError : Maybe (String -> msg)
    , onClose : Maybe msg
    }


type Socket msg
    = Socket (SocketProps msg)


mapSocket : (a -> b) -> Socket a -> Socket b
mapSocket fn (Socket socket) =
    Socket
        { id = socket.id
        , default = socket.default
        , url = socket.url
        , connectOptions = socket.connectOptions
        , onOpen =
            socket.onOpen
                |> Maybe.map ((<<) fn)
        , onError =
            socket.onError
                |> Maybe.map ((<<) fn)
        , onClose =
            socket.onClose
                |> Maybe.map fn
        }


type Msg msg
    = OnOpen String
    | OnClose String
    | OnError PortsAPI.Message
    | OnMessage PortsAPI.Message
    | OnTime Time.Posix


type Effect msg
    = Pub { sid : Maybe String, subject : String, replyTo : Maybe String, message : String }
    | Open (Socket msg)
    | Close String
    | Request { sid : Maybe String, subject : String, group : String, message : String, timeout : Maybe Int, onResponse : Result Timeout String -> msg }
    | NoEffect
    | BatchEffect (List (Effect msg))


{-| A way of telling Nats : "Please subscribe to this subject and send
back messages to me".
-}
type Sub msg
    = Subscribe { sid : Maybe String, subject : String, group : String, onMessage : Protocol.Message -> msg }
    | BatchSub (List (Sub msg))
    | NoSub
