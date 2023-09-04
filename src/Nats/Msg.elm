module Nats.Msg exposing (Msg)

{-| Exposes the nats internal Msg

@docs Msg

-}

import Nats.Internal.Types as Types


{-| A nats internal Msg
-}
type alias Msg msg =
    Types.Msg msg
