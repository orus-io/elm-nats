module SubComp exposing (..)

import Html exposing (Html, text, div, img, button, ul, li, p)
import Html.Attributes exposing (src, width, style)
import Html.Events exposing (onClick)
import Nats
import Nats.Protocol exposing (Message)
import Nats.Cmd as NatsCmd
import Nats.Sub as NatsSub


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


receive : Int -> Message -> Msg
receive n natsMessage =
    Receive n natsMessage.data


natsSubscriptions : Model -> NatsSub.Sub Msg
natsSubscriptions model =
    List.range 0 (model.subCounter - 1)
        |> List.map (\n -> receive n |> Nats.subscribe ("test.subject#Subcomp" ++ toString n))
        |> NatsSub.batch


update : Msg -> Model -> ( Model, NatsCmd.Cmd Msg, Cmd Msg )
update msg model =
    case msg of
        Subscribe ->
            ( { model
                | subCounter = model.subCounter + 1
              }
            , NatsCmd.none
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
            , NatsCmd.none
            , Cmd.none
            )

        Receive n data ->
            ( { model
                | received = (toString n ++ ": " ++ data) :: model.received
              }
            , NatsCmd.none
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div [ style [ ( "border", "1px" ) ] ]
        [ p [] [ text "The Subscribe button add a new subscription to 'test.subject'." ]
        , button
            [ onClick Subscribe ]
            [ text "Subscribe" ]
        , button
            [ onClick Unsubscribe ]
            [ text "Unsubscribe" ]
        , p [] [ text "Here are the received messages, prefixed with a subscription id (most recent are on top):" ]
        , ul [] <|
            List.map
                (text >> List.singleton >> li [])
                model.received
        ]
