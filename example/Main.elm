port module Main exposing (main)

import Browser
import Cmd.Extra exposing (addCmd, addCmds, withCmd, withCmds)
import Html exposing (Html, a, button, div, h1, h3, h4, img, input, label, li, p, text, ul)
import Html.Attributes exposing (class, href, placeholder, src, style, type_, width)
import Html.Events exposing (onClick, onInput)
import Nats
import Nats.Cmd as NatsCmd
import Nats.Errors exposing (Timeout)
import Nats.Protocol
import Nats.Sub as NatsSub
import SubComp



---- PORTS ----


port natsSend : String -> Cmd msg


port natsReceive : (String -> msg) -> Sub msg



---- MODEL ----


type alias Model =
    { nats : Nats.State Msg
    , subcomp : SubComp.Model
    , inputText : String
    , response : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init () =
    let
        nats =
            Nats.init
                |> Nats.setName "elm-nats-demo"
    in
    mergeNats
        ( { nats = { nats | debug = True }
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
    | NatsConnect Nats.Protocol.ServerInfo
    | Publish
    | InputText String
    | SendRequest
    | RequestError
    | ReceiveResponse String
    | HandleRequest Nats.Protocol.Message


receiveResponse : Result Timeout Nats.Protocol.Message -> Msg
receiveResponse result =
    case result of
        Ok message ->
            ReceiveResponse message.data

        Err _ ->
            RequestError


handleNatsSideEffects : List (Nats.SideEffect Msg) -> Model -> ( Model, Cmd Msg )
handleNatsSideEffects =
    Nats.handleNatsSideEffects
        { update = update
        , tagger = NatsMsg
        , natsSend = natsSend
        }


mergeNats : ( Model, NatsCmd.Cmd Msg, Cmd Msg ) -> ( Model, Cmd Msg )
mergeNats ( model, natsCmd, cmd ) =
    let
        ( natsState, sideEffects ) =
            Nats.merge model.nats (natsSubscriptions model) natsCmd
    in
    handleNatsSideEffects sideEffects
        { model
            | nats = natsState
        }
        |> addCmd cmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    mergeNats
        (case msg of
            NatsMsg natsMsg ->
                let
                    ( nats, sideEffects ) =
                        Nats.update natsMsg model.nats

                    ( newModel, cmd ) =
                        handleNatsSideEffects sideEffects
                            { model
                                | nats = nats
                            }
                in
                ( newModel
                , NatsCmd.none
                , cmd
                )

            SubCompMsg subcompMsg ->
                let
                    ( subcomp, subcompNatsCmd, subcompCmd ) =
                        SubComp.update subcompMsg model.subcomp
                in
                ( { model
                    | subcomp = subcomp
                  }
                , NatsCmd.map SubCompMsg subcompNatsCmd
                , Cmd.map SubCompMsg subcompCmd
                )

            NatsConnect info ->
                ( model
                , Nats.publish "test.subject" (Debug.toString info)
                , Cmd.none
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

            RequestError ->
                ( { model | response = Just "Sorry, timeout error... Try again later?" }
                , NatsCmd.none
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


panel : List (Html Msg) -> Html Msg
panel body =
    div [ class "panel panel-default" ]
        [ div [ class "panel-body" ]
            body
        ]


scaffolding : List (List (Html Msg)) -> Html Msg
scaffolding boxes =
    div
        [ class "container"
        ]
        [ div [ class "header clearfix" ]
            [ h3 [ class "text-muted" ] [ text "Elm NATS" ]
            ]
        , let
            ( col1, col2 ) =
                List.partition (\( n, box ) -> modBy 2 n == 0) <|
                    List.map2
                        (\n box -> ( n, panel box ))
                        (List.range 0 50)
                        boxes
          in
          div [ class "row" ]
            [ div [ class "col-sm-12" ]
                [ panel
                    [ h1 [] [ text "Elm NATS demonstration mini-app" ]
                    , p [] [ text "This mini-app demonstration pub, sub and req/rep" ]
                    ]
                ]
            , div [ class "col-sm-6" ] <|
                List.map Tuple.second <|
                    col1
            , div [ class "col-sm-6" ] <|
                List.map Tuple.second <|
                    col2
            ]
        ]


view : Model -> Browser.Document Msg
view model =
    let
        ready =
            case model.nats.serverInfo of
                Just _ ->
                    True

                Nothing ->
                    False
    in
    { title = "Elm Nats Demo"
    , body =
        [ scaffolding <|
            [ [ h4 [] [ text "Here is what we know about the NATS server" ]
              , case model.nats.serverInfo of
                    Just info ->
                        ul []
                            [ li [] [ text ("Server ID: " ++ info.server_id) ]
                            , li [] [ text ("Version: " ++ info.version) ]
                            , li [] [ text ("Go version: " ++ info.go) ]
                            ]

                    Nothing ->
                        div [ class "alert alert-warning" ]
                            [ text "Problem: No connection established (yet?). This app need a running "
                            , a [ href "https://github.com/nats-io/gnatsd/" ]
                                [ text "gnatsd" ]
                            , text " and a running "
                            , a [ href "https://github.com/orus-io/nats-websocket-gw" ]
                                [ text "nats-websocket-gw" ]
                            , text " --no-origin-check"
                            ]
              ]
            , [ h4 [] [ text "Publish" ]
              , p [] [ text "The Publish button sends 'Hi' on 'test.subject'." ]
              , button
                    [ class "btn btn-primary"
                    , onClick Publish
                    ]
                    [ text "Publish" ]
              ]
            , [ h4 [] [ text "A req/rep demo" ]
              , input
                    [ class "form-control"
                    , type_ "text"
                    , onInput InputText
                    , placeholder "Your name"
                    ]
                    []
              , button
                    [ class "btn btn-primary"
                    , onClick SendRequest
                    ]
                    [ text "Say hello !" ]
              , case model.response of
                    Just response ->
                        text response

                    Nothing ->
                        text ""
              ]
            , [ SubComp.view model.subcomp
                    |> Html.map SubCompMsg
              ]
            ]
        ]
    }



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.document
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
        , Nats.onConnect NatsConnect
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ natsReceive Nats.receive
        , Nats.listen
            model.nats
        ]
        |> Sub.map NatsMsg
