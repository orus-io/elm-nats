module SubComp exposing (Model, Msg(..), init, natsSubscriptions, receive, update, view)

import Bytes exposing (Bytes)
import Bytes.Decode
import Bytes.Encode
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
    | Receive Int Bytes


type alias Model =
    { received : List String
    , subCounter : Int
    }


init : Model
init =
    { received = []
    , subCounter = 0
    }


receive : Int -> Message Bytes -> Msg
receive n natsMessage =
    Receive n natsMessage.data


natsSubscriptions : Model -> Nats.Sub Bytes Msg
natsSubscriptions model =
    List.range 0 (model.subCounter - 1)
        |> List.map (\n -> receive n |> Nats.subscribe "test.subject")
        |> Nats.Sub.batch


update : Msg -> Model -> ( Model, Nats.Effect Bytes Msg, Cmd Msg )
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
                            | received = 
            case
                    Bytes.Decode.decode
                    (Bytes.Decode.string (Bytes.width data) )
                    data
                    of
                        Just s ->
                                (String.fromInt n ++ ": " ++ s) :: model.received
                        Nothing ->
                            "could not decode message" :: model.received
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
