module Nats.Sub exposing
    ( Sub(..), map, batch, none
    , tag, socket
    )

{-| Nats Subscription types

This module mimics Platform.Sub, but for Nats subscriptions

@docs Sub, map, batch, none

@docs tag, socket

-}

import Nats.Errors exposing (Timeout)
import Nats.Protocol as Protocol


{-| A way of telling Nats : "Please subscribe to this subject and send
back messages to me".
-}
type Sub msg
    = Subscribe { sid : Maybe String, subject : String, group : String, onMessage : Protocol.Message -> msg }
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
        Subscribe { sid, subject, group, onMessage } ->
            Subscribe
                { sid = sid
                , subject = subject
                , group = group
                , onMessage = onMessage >> aToMsg
                }

        BatchSub list ->
            BatchSub <| List.map (map aToMsg) list

        None ->
            None


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
        Subscribe props ->
            Subscribe props

        BatchSub list ->
            list
                |> List.map (tag atag)
                |> BatchSub

        any ->
            any


{-| Set a different socket id on the subscription
-}
socket : String -> Sub msg -> Sub msg
socket sid sub =
    case sub of
        Subscribe props ->
            Subscribe { props | sid = Just sid }

        BatchSub list ->
            list
                |> List.map (socket sid)
                |> BatchSub

        any ->
            any


{-| An null subscription
-}
none : Sub msg
none =
    None
