module Nats.Errors exposing (Timeout)

{-| Nats errors

@docs Timeout

-}

import Time exposing (Posix)


{-| A timeout error. The value is the time at which the timeout
was triggered
-}
type alias Timeout =
    Posix
