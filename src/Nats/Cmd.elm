module Nats.Cmd
    exposing
        ( Cmd(..)
        , map
        , batch
        , none
        )

{-| Nats command types

This module mimics Platform.Cmd, but for Nats commands

@docs Cmd, map, batch, none

-}

import Nats.Protocol as Protocol
import Nats.Errors exposing (Timeout)


{-| A Nats command
-}
type Cmd msg
    = Publish String String
    | Request String String (Result Timeout Protocol.Message -> msg)
    | Batch (List (Cmd msg))
    | None


{-| Transform the commands produced by some update function
-}
map : (a -> msg) -> Cmd a -> Cmd msg
map aToMsg cmd =
    case cmd of
        Publish subject data ->
            Publish subject data

        Request subject data tagger ->
            Request subject data (tagger >> aToMsg)

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
