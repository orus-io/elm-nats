module Main exposing (main)

import Html exposing (Html, text, div, img, button, ul, li, p)
import Html.Attributes exposing (src, width, style)
import Html.Events exposing (onClick)
import Nats
import SubComp


---- MODEL ----


type alias Model =
    { nats : Nats.State Msg
    , subcomp : SubComp.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { nats = Nats.init "ws://localhost:8910/nats"
      , subcomp = SubComp.init
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | NatsMsg Nats.Msg
    | SubCompMsg SubComp.Msg
    | Publish


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NatsMsg natsMsg ->
            let
                ( nats, natsCmd ) =
                    Nats.update natsMsg model.nats
            in
                { model
                    | nats = nats
                }
                    ! [ Cmd.map NatsMsg natsCmd ]

        SubCompMsg subcompMsg ->
            let
                ( subcomp, subcompNatsCmd, subcompCmd ) =
                    SubComp.update subcompMsg model.subcomp

                ( nats, natsCmd ) =
                    Nats.applyNatsCmd model.nats <|
                        Nats.map SubCompMsg subcompNatsCmd
            in
                { model
                    | nats = nats
                    , subcomp = subcomp
                }
                    ! [ Cmd.map NatsMsg natsCmd
                      , Cmd.map SubCompMsg subcompCmd
                      ]

        Publish ->
            model
                ! [ Nats.publish model.nats "test.subject" "Hi" |> Cmd.map NatsMsg
                  ]

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "text-align", "center" )
            ]
        ]
        [ p [] [ text "A Elm Nats demonstration" ]
        , p [] [ text "Here is what we know about the NATS server" ]
        , p []
            [ case model.nats.serverInfo of
                Just info ->
                    ul []
                        [ li [] [ text ("Server ID: " ++ info.server_id) ]
                        , li [] [ text ("Version: " ++ info.version) ]
                        , li [] [ text ("Go version: " ++ info.go) ]
                        ]

                Nothing ->
                    text "Nothing !"
            ]
        , p [] [ text "The Publish button Each push on Subscribe creates a new subscription." ]
        , button
            [ onClick Publish ]
            [ text "Publish" ]
        , SubComp.view model.subcomp |> Html.map SubCompMsg
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Nats.listen model.nats NatsMsg
