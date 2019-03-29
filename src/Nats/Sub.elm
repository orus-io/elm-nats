module Nats.Sub exposing (Sub(..), map, batch, none)

{-| Nats Subscription types

This module mimics Platform.Sub, but for Nats subscriptions

@docs Sub, map, batch, none

-}

import Nats.Errors exposing (Timeout)
import Nats.Protocol as Protocol


{-| A way of telling Nats : "Please subscribe to this subject and send
back messages to me".
-}
type Sub msg
    = Subscribe String String (Protocol.Message -> msg)
    | RequestSubscribe String String (Result Timeout Protocol.Message -> msg)
    | OnConnect (Protocol.ServerInfo -> msg)
    | OnError (String -> msg)
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

        l ->
            if 1 == List.length l then
                Maybe.withDefault none <| List.head l

            else
                BatchSub l


{-| Map a Sub a to a Sub msg
-}
map : (a -> msg) -> Sub a -> Sub msg
map aToMsg sub =
    case sub of
        Subscribe subject queueGroup tagger ->
            Subscribe subject queueGroup <| tagger >> aToMsg

        RequestSubscribe subject request tagger ->
            RequestSubscribe subject request <| tagger >> aToMsg

        OnConnect tagger ->
            OnConnect <| tagger >> aToMsg

        OnError tagger ->
            OnError <| tagger >> aToMsg

        BatchSub list ->
            BatchSub <| List.map (map aToMsg) list

        None ->
            None


{-| An null subscription
-}
none : Sub msg
none =
    None
