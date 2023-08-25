module Nats.Nuid exposing (Nuid, new, next)

import Random exposing (Generator)
import Random.Char
import Random.Extra
import Random.String


defaultLen : Int
defaultLen =
    22


num : Generator Char
num =
    Random.Char.char 0x30 0x39


alphaNum : Generator Char
alphaNum =
    Random.Extra.choices
        Random.Char.lowerCaseLatin
        [ Random.Char.upperCaseLatin
        , num
        ]


type Nuid
    = Nuid Int (Generator Char) Random.Seed


new : Random.Seed -> Nuid
new =
    Nuid defaultLen alphaNum


next : Nuid -> ( String, Nuid )
next (Nuid len charGen seed) =
    let
        ( value, nextSeed ) =
            seed
                |> Random.step (Random.String.string len charGen)
    in
    ( value, Nuid len charGen nextSeed )
