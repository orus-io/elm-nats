module Nats.Sub exposing
    ( map, batch, none
    , tag, socket
    )

{-| Nats Subscription types

This module mimics Platform.Sub, but for Nats subscriptions

@docs map, batch, none

@docs tag, socket

-}

import Nats exposing (Sub)
import Nats.Errors exposing (Timeout)
import Nats.Internal.Types as Types
import Nats.Protocol as Protocol


{-| Batch several subscriptions
-}
batch : List (Sub msg) -> Sub msg
batch list =
    case
        List.filter
            (\v ->
                case v of
                    Types.NoSub ->
                        False

                    _ ->
                        True
            )
            list
    of
        [] ->
            Types.NoSub

        l ->
            if 1 == List.length l then
                Maybe.withDefault none <| List.head l

            else
                Types.BatchSub l


{-| Map a Sub a to a Sub msg
-}
map : (a -> msg) -> Sub a -> Sub msg
map aToMsg sub =
    case sub of
        Types.Subscribe { sid, subject, group, onMessage } ->
            Types.Subscribe
                { sid = sid
                , subject = subject
                , group = group
                , onMessage = onMessage >> aToMsg
                }

        Types.BatchSub list ->
            Types.BatchSub <| List.map (map aToMsg) list

        Types.NoSub ->
            Types.NoSub


tagSubject : String -> String -> String
tagSubject atag subject =
    case String.split "#" subject |> List.reverse of
        [] ->
            "#" ++ atag

        [ s ] ->
            s ++ "#" ++ atag

        t :: s ->
            (t ++ "_" ++ atag)
                :: s
                |> List.reverse
                |> String.join "#"


{-| Add a #tag to the subscription(s) subject
Id the subject already has a tag, the two are combined with a '\_' separator
-}
tag : String -> Sub msg -> Sub msg
tag atag sub =
    case sub of
        Types.Subscribe props ->
            Types.Subscribe props

        Types.BatchSub list ->
            list
                |> List.map (tag atag)
                |> Types.BatchSub

        any ->
            any


{-| Set a different socket id on the subscription
-}
socket : String -> Sub msg -> Sub msg
socket sid sub =
    case sub of
        Types.Subscribe props ->
            Types.Subscribe { props | sid = Just sid }

        Types.BatchSub list ->
            list
                |> List.map (socket sid)
                |> Types.BatchSub

        any ->
            any


{-| An null subscription
-}
none : Sub msg
none =
    Types.NoSub
