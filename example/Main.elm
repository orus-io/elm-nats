module Main exposing (main)

import Html exposing (Html, text, div, img, button, ul, li, p, input, label)
import Html.Attributes exposing (src, width, style, type_)
import Html.Events exposing (onClick, onInput)
import Nats
import Nats.Protocol
import SubComp


---- MODEL ----


type alias Model =
    { nats : Nats.State Msg
    , subcomp : SubComp.Model
    , inputText : String
    , response : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    let
        ( nats, natsCmd ) =
            Nats.applyNatsCmd
                (Nats.init "ws://localhost:8910/nats")
                (Nats.subscribe "say.hello.to.me" HandleRequest)
    in
        ( { nats = nats
          , subcomp = SubComp.init
          , inputText = ""
          , response = Nothing
          }
        , Cmd.map NatsMsg natsCmd
        )



---- UPDATE ----


type Msg
    = NoOp
    | NatsMsg Nats.Msg
    | SubCompMsg SubComp.Msg
    | Publish
    | InputText String
    | SendRequest
    | ReceiveResponse String
    | HandleRequest Nats.Protocol.Message


applyNatsCmd : Model -> Cmd Msg -> Nats.NatsCmd Msg -> ( Model, Cmd Msg )
applyNatsCmd model cmd natsCmd =
    let
        ( nats, extraCmd ) =
            Nats.applyNatsCmd model.nats natsCmd
    in
        { model
            | nats = nats
        }
            ! [ cmd, Cmd.map NatsMsg extraCmd ]


receiveResponse : Nats.Protocol.Message -> Msg
receiveResponse message =
    ReceiveResponse message.data


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
            in
                applyNatsCmd
                    { model
                        | subcomp = subcomp
                    }
                    (Cmd.map SubCompMsg subcompCmd)
                    (Nats.map SubCompMsg subcompNatsCmd)

        Publish ->
            applyNatsCmd model Cmd.none <| Nats.publish "test.subject" "Hi"

        HandleRequest message ->
            applyNatsCmd model Cmd.none <| Nats.publish message.replyTo ("Hello " ++ message.data ++ "!")

        InputText text ->
            { model
                | inputText = text
            }
                ! []

        SendRequest ->
            applyNatsCmd model Cmd.none <|
                Nats.request "say.hello.to.me" model.inputText receiveResponse

        ReceiveResponse response ->
            { model | response = Just response } ! []

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
        , div []
            [ text "A req/rep demo"
            , label []
                [ text "Your name: "
                , input [ type_ "text", onInput InputText ] []
                ]
            , button [ onClick SendRequest ] [ text "Say hello !" ]
            , case model.response of
                Just response ->
                    text response

                Nothing ->
                    text ""
            ]
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
