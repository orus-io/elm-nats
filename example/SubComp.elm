module SubComp exposing (..)

import Html exposing (Html, text, div, img, button, ul, li, p)
import Html.Attributes exposing (src, width, style)
import Html.Events exposing (onClick)
import Nats


type Msg
    = Subscribe
    | Receive String String


type alias Model =
    { received : List String
    }


init : Model
init =
    { received = []
    }


receive : Nats.NatsMessage -> Msg
receive natsMessage =
    Receive natsMessage.sid natsMessage.payload


update : Msg -> Model -> ( Model, List (Nats.Subscription Msg), Cmd Msg )
update msg model =
    case msg of
        Subscribe ->
            ( model, [ Nats.subscribe "test.subject" receive ], Cmd.none )

        Receive sid data ->
            ( { model
                | received = (sid ++ ": " ++ data) :: model.received
              }
            , []
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div [ style [ ( "border", "1px" ) ] ]
        [ p [] [ text "The Subscribe button creates a new subscription to 'test.subject'." ]
        , button
            [ onClick Subscribe ]
            [ text "Subscribe" ]
        , p [] [ text "Here are the received messages, prefixed with their subscription ID (most recent are on top):" ]
        , ul [] <|
            List.map
                (text >> List.singleton >> li [])
                model.received
        ]
