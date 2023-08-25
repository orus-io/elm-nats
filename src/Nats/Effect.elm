module Nats.Effect exposing (none, map, batch, onSocket)

{-| The Nats Effect API

If you are familiar with the core Cmd api, you will feel at home here

@docs none, map, batch, onSocket

-}

import Nats exposing (Effect)
import Nats.Internal.Types as Types


{-| Tell nats there are no effect
-}
none : Effect msg
none =
    Types.NoEffect


{-| Batch several nats effect, pretty much like Cmd.batch
-}
batch : List (Effect msg) -> Effect msg
batch =
    Types.BatchEffect


{-| Transform the messages produced by an effect
-}
map : (a -> b) -> Effect a -> Effect b
map fn effect =
    case effect of
        Types.Open socket ->
            Types.Open <| Types.mapSocket fn socket

        Types.Close id ->
            Types.Close id

        Types.Pub pub ->
            Types.Pub pub

        Types.Request { sid, subject, group, message, onResponse, timeout } ->
            Types.Request
                { sid = sid
                , subject = subject
                , group = group
                , message = message
                , onResponse = onResponse >> fn
                , timeout = timeout
                }

        Types.BatchEffect list ->
            Types.BatchEffect <| List.map (map fn) list

        Types.NoEffect ->
            Types.NoEffect


{-| Set / change the socket on which the effect should apply
-}
onSocket : String -> Effect msg -> Effect msg
onSocket sid effect =
    case effect of
        Types.Open socket ->
            Types.Open socket

        Types.Close _ ->
            Types.Close sid

        Types.Pub props ->
            Types.Pub { props | sid = Just sid }

        Types.Request req ->
            Types.Request { req | sid = Just sid }

        Types.BatchEffect list ->
            Types.BatchEffect <| List.map (onSocket sid) list

        Types.NoEffect ->
            Types.NoEffect
