module Nats.Effect exposing (none, map, batch, onSocket, setRequestMarker)

{-| The Nats Effect API

If you are familiar with the core Cmd api, you will feel at home here

@docs none, map, batch, onSocket, setRequestMarker

-}

import Nats exposing (Effect)
import Nats.Internal.Types as Types


{-| Tell nats there are no effect
-}
none : Effect datatype msg
none =
    Types.NoEffect


{-| Batch several nats effect, pretty much like Cmd.batch
-}
batch : List (Effect datatype msg) -> Effect datatype msg
batch =
    Types.BatchEffect


{-| Transform the messages produced by an effect
-}
map : (a -> b) -> Effect datatype a -> Effect datatype b
map fn effect =
    case effect of
        Types.Pub pub ->
            Types.Pub pub

        Types.Request { sid, marker, subject, replyTo, message, onTimeout, onResponse, timeout } ->
            Types.Request
                { sid = sid
                , marker = marker
                , subject = subject
                , replyTo = replyTo
                , message = message
                , onTimeout = onTimeout >> fn
                , onResponse = onResponse >> Tuple.mapFirst (Maybe.map fn)
                , timeout = timeout
                }

        Types.CancelRequest req ->
            Types.CancelRequest req

        Types.BatchEffect list ->
            Types.BatchEffect <| List.map (map fn) list

        Types.NoEffect ->
            Types.NoEffect


{-| Set / change the socket on which the effect should apply
-}
onSocket : String -> Effect datatype msg -> Effect datatype msg
onSocket sid effect =
    case effect of
        Types.Pub props ->
            Types.Pub { props | sid = Just sid }

        Types.Request req ->
            Types.Request { req | sid = Just sid }

        Types.CancelRequest req ->
            Types.CancelRequest { req | sid = Just sid }

        Types.BatchEffect list ->
            Types.BatchEffect <| List.map (onSocket sid) list

        Types.NoEffect ->
            Types.NoEffect


{-| if the effect is a single request, set its marker to the given one
-}
setRequestMarker : String -> Effect datatype msg -> Effect datatype msg
setRequestMarker marker effect =
    case effect of
        Types.Request req ->
            Types.Request { req | marker = Just marker }

        _ ->
            effect
