module Main exposing (main)

import Html exposing (Html, text, div, img, button, ul, li, p)
import Html.Attributes exposing (src, width, style)
import Html.Events exposing (onClick)
import Nats


---- MODEL ----


type alias Model =
    { nats : Nats.State Msg
    , received : List String
    }


init : ( Model, Cmd Msg )
init =
    ( { nats = Nats.init "ws://localhost:8910/nats"
      , received = []
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | NatsMsg Nats.Msg
    | Subscribe
    | Publish
    | Receive Nats.NatsMessage


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

        Subscribe ->
            let
                ( nats, natsCmd ) =
                    Nats.setupSubscription model.nats <|
                        Nats.subscribe "test.subject" Receive
            in
                { model
                    | nats = nats
                }
                    ! [ Cmd.map NatsMsg natsCmd ]

        Publish ->
            model
                ! [ Nats.publish model.nats "test.subject" "Hi" |> Cmd.map NatsMsg
                  ]

        Receive natsMessage ->
            { model
                | received = (natsMessage.sid ++ ": " ++ natsMessage.payload) :: model.received
            }
                ! []

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
        , p [] [ text "The Subscribe button creates a new subscription to 'test.subject'." ]
        , button
            [ onClick Subscribe ]
            [ text "Subscribe" ]
        , p [] [ text "The Publish button Each push on Subscribe creates a new subscription." ]
        , button
            [ onClick Publish ]
            [ text "Publish" ]
        , p [] [ text "Here are the received messages, prefixed with their subscription ID (most recent are on top):" ]
        , ul [] <|
            List.map
                (text >> List.singleton >> li [])
                model.received
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
