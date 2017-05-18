module SubComp exposing (..)

import Html exposing (Html, text, div, img, button, ul, li, p)
import Html.Attributes exposing (src, width, style)
import Html.Events exposing (onClick)
import Nats
import Nats.Protocol exposing (Message)


type Msg
    = Subscribe
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


receive : Int -> Message -> Msg
receive n natsMessage =
    Receive n natsMessage.data


update : Msg -> Model -> ( Model, Nats.NatsCmd Msg, Cmd Msg )
update msg model =
    case msg of
        Subscribe ->
            ( { model
                | subCounter = model.subCounter + 1
              }
            , Nats.subscribe "test.subject" <| receive model.subCounter
            , Cmd.none
            )

        Receive n data ->
            ( { model
                | received = (toString n ++ ": " ++ data) :: model.received
              }
            , Nats.none
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div [ style [ ( "border", "1px" ) ] ]
        [ p [] [ text "The Subscribe button creates a new subscription to 'test.subject'." ]
        , button
            [ onClick Subscribe ]
            [ text "Subscribe" ]
        , p [] [ text "Here are the received messages, prefixed with a subscription id (most recent are on top):" ]
        , ul [] <|
            List.map
                (text >> List.singleton >> li [])
                model.received
        ]
