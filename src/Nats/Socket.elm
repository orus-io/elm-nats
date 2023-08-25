module Nats.Socket exposing
    ( Status(..), Socket
    , new, setDefault
    , withAuthToken, withUserPass
    , onOpen, onClose, onError
    )

{-| A socket defines a connection to a nats server

@docs Status, Socket

@docs new, setDefault


# Authentication

@docs withAuthToken, withUserPass


# Events

@docs onOpen, onClose, onError

-}

import Nats.Internal.Types as Types
import Nats.Protocol exposing (ServerInfo)


{-| Representation of a Nats connection properties
-}
type alias Socket msg =
    Types.Socket msg


{-| Possible statuses of a socket
-}
type Status
    = Undefined
    | Opening
    | Opened
    | Closing
    | Closed
    | Error String


{-| Initialize a Socket with a unique ID and a endpoint url

The 'sid' can be used in various places of the API to choose which socket
should handle an effect or a subscription.

-}
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


{-| Authenticate with a username and a password
-}
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


{-| Authenticate with a auth token
-}
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


{-| Set this socket as the default one

If an app has several opened sockets, one must be the default one. By default,
the default socket is the first to be opened. This function can be used to
designate an arbitrary socket as the default one.

If several sockets have this flag, one of them will be picked

-}
setDefault : Socket msg -> Socket msg
setDefault (Types.Socket socket) =
    Types.Socket
        { socket
            | default = True
        }


{-| Set a handler message for when the connection is opened

At the moment the message is received, the authentication may not be complete
yet, in which case the connection will be closed with an error very quickly after

-}
onOpen : (ServerInfo -> msg) -> Socket msg -> Socket msg
onOpen msg (Types.Socket socket) =
    Types.Socket
        { socket
            | onOpen = Just msg
        }


{-| Set a handler message for when the connection is properly closed
-}
onClose : msg -> Socket msg -> Socket msg
onClose msg (Types.Socket socket) =
    Types.Socket
        { socket
            | onClose = Just msg
        }


{-| Set a handler message for when the connection is closed with error of cannot
be opened at all
-}
onError : (String -> msg) -> Socket msg -> Socket msg
onError msg (Types.Socket socket) =
    Types.Socket
        { socket
            | onError = Just msg
        }
