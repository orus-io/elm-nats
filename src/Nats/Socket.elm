module Nats.Socket exposing
    ( Status(..), Socket
    , new, setDefault, withDebug
    , connectOptions
    , withAuthToken, withUserPass
    )

{-| A socket defines a connection to a nats server

@docs Status, Socket

@docs new, setDefault, withDebug


# Authentication

@docs connectOptions
@docs withAuthToken, withUserPass

-}

import Nats.Internal.Types as Types
import Nats.Protocol exposing (ConnectOptions)


{-| Representation of a Nats connection properties
-}
type alias Socket =
    Types.Socket


{-| Possible statuses of a socket
-}
type Status
    = Undefined
    | Opening
    | Opened
    | Connecting
    | Connected
    | Closing
    | Closed
    | Error String


{-| Initialize a Socket with a unique ID and a endpoint url

The 'sid' can be used in various places of the API to choose which socket
should handle an effect or a subscription.

-}
new : String -> String -> Socket
new sid url =
    Types.Socket
        { id = sid
        , default = False
        , url = url
        , debug = False
        }


{-| Enable/disable debug mode on the socket

If the Config debug is on, all sockets will have debug enabled no matter what
value is given to this function.

-}
withDebug : Bool -> Socket -> Socket
withDebug value (Types.Socket props) =
    Types.Socket
        { props
            | debug = value
        }


{-| Build the smallest ConnectOptions possible

You generally want to combine it with 'withUserPass' or 'withAuthToken'

-}
connectOptions : String -> String -> ConnectOptions
connectOptions name version =
    { name = Just name
    , verbose = False
    , pedantic = False
    , auth_token = Nothing
    , user = Nothing
    , pass = Nothing
    , protocol = 0
    , version = version
    , lang = "elm"
    }


{-| Authenticate with a username and a password
-}
withUserPass : String -> String -> ConnectOptions -> ConnectOptions
withUserPass user pass options =
    { options
        | user = Just user
        , pass = Just pass
    }


{-| Authenticate with a auth token
-}
withAuthToken : String -> ConnectOptions -> ConnectOptions
withAuthToken auth_token options =
    { options
        | auth_token = Just auth_token
    }


{-| Set this socket as the default one

If an app has several opened sockets, one must be the default one. By default,
the default socket is the first to be opened. This function can be used to
designate an arbitrary socket as the default one.

If several sockets have this flag, one of them will be picked

-}
setDefault : Socket -> Socket
setDefault (Types.Socket socket) =
    Types.Socket
        { socket
            | default = True
        }
