module Main exposing (main)

import Html exposing (Html, text, div, img, button, ul, li, p, input, label)
import Html.Attributes exposing (src, width, style, type_)
import Html.Events exposing (onClick, onInput)
import Nats
import Nats.Protocol
import Nats.Cmd as NatsCmd
import Nats.Sub as NatsSub
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
    mergeNats
        ( { nats = Nats.init "ws://localhost:8910/nats"
          , subcomp = SubComp.init
          , inputText = ""
          , response = Nothing
          }
        , NatsCmd.none
        , Cmd.none
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


receiveResponse : Nats.Protocol.Message -> Msg
receiveResponse message =
    ReceiveResponse message.data


mergeNats : ( Model, NatsCmd.Cmd Msg, Cmd Msg ) -> ( Model, Cmd Msg )
mergeNats ( model, natsCmd, cmd ) =
    let
        ( natsState, extraCmd ) =
            Nats.merge model.nats (natsSubscriptions model) natsCmd
    in
        { model
            | nats = natsState
        }
            ! [ cmd, Cmd.map NatsMsg extraCmd ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    mergeNats
        (case msg of
            NatsMsg natsMsg ->
                let
                    ( nats, natsCmd ) =
                        Nats.update natsMsg model.nats
                in
                    ( { model
                        | nats = nats
                      }
                    , NatsCmd.none
                    , Cmd.map NatsMsg natsCmd
                    )

            SubCompMsg subcompMsg ->
                let
                    ( subcomp, subcompNatsCmd, subcompCmd ) =
                        SubComp.update subcompMsg model.subcomp
                in
                    ( { model
                        | subcomp = subcomp
                      }
                    , (NatsCmd.map SubCompMsg subcompNatsCmd)
                    , (Cmd.map SubCompMsg subcompCmd)
                    )

            Publish ->
                ( model
                , Nats.publish "test.subject" "Hi"
                , Cmd.none
                )

            HandleRequest message ->
                ( model
                , Nats.publish message.replyTo ("Hello " ++ message.data ++ "!")
                , Cmd.none
                )

            InputText text ->
                ( { model
                    | inputText = text
                  }
                , NatsCmd.none
                , Cmd.none
                )

            SendRequest ->
                ( model
                , Nats.request "say.hello.to.me" model.inputText receiveResponse
                , Cmd.none
                )

            ReceiveResponse response ->
                ( { model | response = Just response }
                , NatsCmd.none
                , Cmd.none
                )

            NoOp ->
                ( model
                , NatsCmd.none
                , Cmd.none
                )
        )



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


natsSubscriptions : Model -> NatsSub.Sub Msg
natsSubscriptions model =
    NatsSub.batch
        [ Nats.subscribe "say.hello.to.me" HandleRequest
        , NatsSub.map SubCompMsg <| SubComp.natsSubscriptions model.subcomp
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Nats.listen model.nats NatsMsg
