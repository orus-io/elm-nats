module SubComp exposing (Model, Msg(..), init, natsSubscriptions, receive, update, view)

import Html exposing (Html, button, div, h4, img, li, p, text, ul)
import Html.Attributes exposing (class, src, style, width)
import Html.Events exposing (onClick)
import Nats
import Nats.Protocol exposing (Message)
import Nats.Effect
import Nats.Sub


type Msg
    = Subscribe
    | Unsubscribe
    | Receive Int String


type alias Model =
    { received : List String
    , subCounter : Int
    }


init : Model
init =
    { received = []
    , subCounter = 0
    }


receive : Int -> Message String -> Msg
receive n natsMessage =
    Receive n natsMessage.data


natsSubscriptions : Model -> Nats.Sub String Msg
natsSubscriptions model =
    List.range 0 (model.subCounter - 1)
        |> List.map (\n -> receive n |> Nats.subscribe "test.subject")
        |> Nats.Sub.batch


update : Msg -> Model -> ( Model, Nats.Effect String Msg, Cmd Msg )
update msg model =
    case msg of
        Subscribe ->
            ( { model
                | subCounter = model.subCounter + 1
              }
            , Nats.Effect.none
            , Cmd.none
            )

        Unsubscribe ->
            ( { model
                | subCounter =
                    if model.subCounter > 0 then
                        model.subCounter - 1

                    else
                        0
              }
            , Nats.Effect.none
            , Cmd.none
            )

        Receive n data ->
            ( { model
                | received = (String.fromInt n ++ ": " ++ data) :: model.received
              }
            , Nats.Effect.none
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ h4 [] [ text "Subscribe" ]
        , p [] [ text "The Subscribe button add a new subscription to 'test.subject'." ]
        , button
            [ class "btn btn-default"
            , onClick Subscribe
            ]
            [ text "Subscribe" ]
        , button
            [ class "btn btn-default"
            , onClick Unsubscribe
            ]
            [ text "Unsubscribe" ]
        , p [] [ text <| "Current subscriptions: " ++ String.fromInt model.subCounter ]
        , p [] [ text "Here are the received messages, prefixed with a subscription id (most recent are on top):" ]
        , ul [] <|
            List.map
                (text >> List.singleton >> li [])
                model.received
        ]
