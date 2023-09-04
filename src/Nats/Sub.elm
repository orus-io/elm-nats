module Nats.Sub exposing
    ( map, batch, none
    , socket
    )

{-| Nats Subscription types

This module mimics Platform.Sub, but for Nats subscriptions

@docs map, batch, none

@docs socket

-}

import Nats
import Nats.Internal.Sub as Internal


{-| Batch several subscriptions
-}
batch : List (Nats.Sub datatype msg) -> Nats.Sub datatype msg
batch =
    Internal.batch


{-| Map a Sub a to a Sub msg
-}
map : (a -> msg) -> Nats.Sub datatype a -> Nats.Sub datatype msg
map =
    Internal.map


{-| Set a different socket id on the subscription
-}
socket : String -> Nats.Sub datatype msg -> Nats.Sub datatype msg
socket =
    Internal.socket


{-| An null subscription
-}
none : Nats.Sub datatype msg
none =
    Internal.none
