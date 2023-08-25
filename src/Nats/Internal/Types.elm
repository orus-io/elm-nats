module Nats.Internal.Types exposing (Msg(..), Socket(..), SocketProps, mapSocket)

import Nats.PortsAPI as PortsAPI
import Nats.Protocol exposing (ConnectOptions, ServerInfo)
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
