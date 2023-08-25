module Nats.Socket exposing
    ( Socket
    , Status(..)
    , new
    , onClose
    , onError
    , onOpen
    , setDefault
    , withAuthToken
    , withUserPass
    )

import Nats.Internal.Types as Types
import Nats.Protocol exposing (ServerInfo)


type alias Socket msg =
    Types.Socket msg


type Status
    = Undefined
    | Opening
    | Opened
    | Closing
    | Closed
    | Error String


new : String -> String -> Socket msg
new sid url =
    Types.Socket
        { id = sid
        , default = False
        , url = url
        , connectOptions =
            { verbose = False
            , pedantic = False
            , auth_token = Nothing
            , user = Nothing
            , pass = Nothing
            , name = Just "nats-rpc/elm-nats"
            , lang = "Elm"
            , version = "0.0.0"
            , protocol = 0
            }
        , onOpen = Nothing
        , onError = Nothing
        , onClose = Nothing
        }


withUserPass : String -> String -> Socket msg -> Socket msg
withUserPass user pass (Types.Socket socket) =
    let
        connectOptions =
            socket.connectOptions
    in
    Types.Socket
        { socket
            | connectOptions =
                { connectOptions
                    | user = Just user
                    , pass = Just pass
                }
        }


withAuthToken : String -> Socket msg -> Socket msg
withAuthToken auth_token (Types.Socket socket) =
    let
        connectOptions =
            socket.connectOptions
    in
    Types.Socket
        { socket
            | connectOptions =
                { connectOptions
                    | auth_token = Just auth_token
                }
        }


setDefault : Socket msg -> Socket msg
setDefault (Types.Socket socket) =
    Types.Socket
        { socket
            | default = True
        }


onOpen : (ServerInfo -> msg) -> Socket msg -> Socket msg
onOpen msg (Types.Socket socket) =
    Types.Socket
        { socket
            | onOpen = Just msg
        }


onClose : msg -> Socket msg -> Socket msg
onClose msg (Types.Socket socket) =
    Types.Socket
        { socket
            | onClose = Just msg
        }


onError : (String -> msg) -> Socket msg -> Socket msg
onError msg (Types.Socket socket) =
    Types.Socket
        { socket
            | onError = Just msg
        }
