module Nats.Sub
    exposing
        ( Sub(..)
        , batch
        , map
        , none
        )

{-| Nats Subscription types

This module mimics Platform.Sub, but for Nats subscriptions

@docs Sub, map, batch, none

-}

import Nats.Protocol as Protocol


{-| A way of telling Nats : "Please subscribe to this subject and send
back messages to me".
-}
type Sub msg
    = Subscribe String String (Protocol.Message -> msg)
    | BatchSub (List (Sub msg))
    | None


{-| Batch several subscriptions
-}
batch : List (Sub msg) -> Sub msg
batch list =
    case
        List.filter
            (\v ->
                case v of
                    None ->
                        False

                    _ ->
                        True
            )
            list
    of
        [] ->
            None

        list ->
            if 1 == List.length list then
                Maybe.withDefault none <| List.head list
            else
                BatchSub list


{-| Map a Sub a to a Sub msg
-}
map : (a -> msg) -> Sub a -> Sub msg
map aToMsg sub =
    case sub of
        Subscribe subject queueGroup tagger ->
            Subscribe subject queueGroup <| tagger >> aToMsg

        BatchSub list ->
            BatchSub <| List.map (map aToMsg) list

        None ->
            None


{-| An null subscription
-}
none : Sub msg
none =
    None
