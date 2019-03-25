module Nats.Cmd exposing (Cmd(..), map, batch, none)

{-| Nats command types

This module mimics Platform.Cmd, but for Nats commands

@docs Cmd, map, batch, none

-}

import Nats.Errors exposing (Timeout)
import Nats.Protocol as Protocol
import Time exposing (Posix)


{-| A Nats command
-}
type Cmd msg
    = Publish String String String
    | Request Float String String (Result Timeout Protocol.Message -> msg)
    | Batch (List (Cmd msg))
    | None


{-| Transform the commands produced by some update function
-}
map : (a -> msg) -> Cmd a -> Cmd msg
map aToMsg cmd =
    case cmd of
        Publish subject replyTo data ->
            Publish subject replyTo data

        Request timeout subject data tagger ->
            Request timeout subject data (tagger >> aToMsg)

        Batch natsCmds ->
            Batch <| List.map (map aToMsg) natsCmds

        None ->
            None


{-| batch several Cmd into one
-}
batch : List (Cmd msg) -> Cmd msg
batch natsCmds =
    Batch natsCmds


{-| A Cmd that does nothing
-}
none : Cmd msg
none =
    None
