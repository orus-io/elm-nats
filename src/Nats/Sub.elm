module Nats.Sub exposing
    ( map, batch, none
    , socket
    )

{-| Nats Subscription types

This module mimics Platform.Sub, but for Nats subscriptions

@docs map, batch, none

@docs tag, socket

-}

import Nats exposing (Sub)
import Nats.Internal.Sub as Internal exposing (RealSub(..), Sub(..))


{-| Batch several subscriptions
-}
batch : List (Sub datatype msg) -> Sub datatype msg
batch =
    Internal.batch


{-| Map a Sub a to a Sub msg
-}
map : (a -> msg) -> Sub datatype a -> Sub datatype msg
map =
    Internal.map


{-| Set a different socket id on the subscription
-}
socket : String -> Sub datatype msg -> Sub datatype msg
socket =
    Internal.socket


{-| An null subscription
-}
none : Sub datatype msg
none =
    Internal.none
