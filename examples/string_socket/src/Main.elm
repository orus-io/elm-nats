port module Main exposing (main)

import Browser
import Html exposing (Html, a, button, div, h1, h3, h4, img, input, label, li, p, text, ul)
import Html.Attributes exposing (class, href, placeholder, src, style, type_, width)
import Html.Events exposing (onClick, onInput)
import Nats
import Nats.Events
import Nats.Effect
import Nats.Config
import Nats.Errors exposing (Timeout)
import Nats.PortsAPI
import Nats.Protocol
import Nats.Socket
import Nats.Sub
import Random
import SubComp
import Time



---- PORTS ----


port natsOpen : Nats.PortsAPI.Open msg


port natsClose : String -> Cmd msg


port natsOnAck : (Nats.PortsAPI.Ack -> msg) -> Sub msg


port natsOnOpen : (String -> msg) -> Sub msg


port natsOnClose : (String -> msg) -> Sub msg


port natsOnError : ({ sid : String, message : String } -> msg) -> Sub msg


port natsOnMessage : (Nats.PortsAPI.Message -> msg) -> Sub msg


port natsSend : Nats.PortsAPI.Message -> Cmd msg


natsConfig : Nats.Config.Config String Msg
natsConfig =
    Nats.Config.string NatsMsg
        { open = natsOpen
        , close = natsClose
        , send = natsSend
        , onAck = natsOnAck
        , onOpen = natsOnOpen
        , onClose = natsOnClose
        , onError = natsOnError
        , onMessage = natsOnMessage
        }
        |> Nats.Config.withDebug True



---- MODEL ----


type alias Model =
    { nats : Nats.State String Msg
    , socket : Nats.Socket.Socket
    , serverInfo : Maybe Nats.Protocol.ServerInfo
    , subcomp : SubComp.Model
    , inputText : String
    , response : Maybe String
    }


init : { now : Int } -> ( Model, Cmd Msg )
init flags =
    let
        nats =
            Nats.init ( Random.initialSeed flags.now )
            (Time.millisToPosix flags.now)
    in
    ({ nats = nats
    , socket = Nats.Socket.new "0" "ws://localhost:8087"
    , serverInfo = Nothing
    , subcomp = SubComp.init
    , inputText = ""
    , response = Nothing
    }
    , Cmd.none
    )


applyNatsEffect : Nats.Effect String Msg -> Model -> ( Model, Cmd Msg )
applyNatsEffect effect model =
    let
        ( nats, cmd ) =
            Nats.applyEffectAndSub natsConfig
                effect
                (natsSubscriptions model)
                model.nats
    in
    ( { model | nats = nats }, cmd )



---- UPDATE ----


type Msg
    = NoOp
    | NatsMsg (Nats.Msg Msg)
    | SubCompMsg SubComp.Msg
    | NatsConnect Nats.Protocol.ServerInfo
    | OnSocketEvent Nats.Events.SocketEvent
    | Publish
    | InputText String
    | SendRequest
    | RequestError
    | ReceiveResponse String
    | HandleRequest (Nats.Protocol.Message String)


receiveResponse : Result Timeout String -> Msg
receiveResponse result =
    case result of
        Ok message ->
            ReceiveResponse message

        Err _ ->
            RequestError


natsSubscriptions : Model -> Nats.Sub String Msg
natsSubscriptions model =
    Nats.Sub.batch
    [
    SubComp.natsSubscriptions model.subcomp
        |> Nats.Sub.map SubCompMsg
        , Nats.groupSubscribe "say.hello.to.me" "server" HandleRequest
        , Nats.connect
        (Nats.Socket.connectOptions "Demo" "0.1"
                            |> Nats.Socket.withUserPass "test" "test"
            )
        model.socket
        OnSocketEvent
        
        ]


updateWrapper : Msg -> Model -> ( Model, Cmd Msg )
updateWrapper msg model =
    let
        ( model1, natsEffect, cmd ) =
            update msg model

        ( model2, natsCmd ) =
            applyNatsEffect natsEffect model1
    in
    ( model2, Cmd.batch [ cmd, natsCmd ] )


update : Msg -> Model -> ( Model, Nats.Effect String Msg, Cmd Msg )
update msg model =
    case msg of
        NatsMsg natsMsg ->
            let
                ( nats, natsCmd ) =
                    Nats.update natsConfig natsMsg model.nats
            in
            ( { model | nats = nats }
            , Nats.Effect.none
            , natsCmd
            )

        OnSocketEvent (Nats.Events.SocketOpen info) ->
            (
                { model
              | serverInfo = Just info
              }
            , Nats.Effect.none
            , Cmd.none
            )

        OnSocketEvent _ ->
            (
              model
            , Nats.Effect.none
            , Cmd.none
            )

        SubCompMsg subcompMsg ->
            let
                ( subcomp, subcompNatsEffect, subcompCmd ) =
                    SubComp.update subcompMsg model.subcomp
            in
            ( { model
                | subcomp = subcomp
              }
            , Nats.Effect.map SubCompMsg subcompNatsEffect
            , Cmd.map SubCompMsg subcompCmd
            )

        {-
           NatsConnect info ->
               ( model
               , Nats.publish "test.subject" (Debug.toString info)
               , Cmd.none
               )

        -}
        HandleRequest message ->
               ( model
               , Nats.publish message.replyTo ("Hello " ++ message.data ++ "!")
               , Cmd.none
               )

        Publish ->
            ( model
            , Nats.publish "test.subject" "Hi"
            , Cmd.none
            )

        InputText text ->
            ( { model
                | inputText = text
              }
            , Nats.Effect.none
            , Cmd.none
            )

        SendRequest ->
           ( model
           , Nats.request "say.hello.to.me" model.inputText receiveResponse
           , Cmd.none
           )

        RequestError ->
           ( { model | response = Just "Sorry, timeout error... Try again later?" }
           , Nats.Effect.none
           , Cmd.none
           )

        ReceiveResponse response ->
           ( { model | response = Just response }
           , Nats.Effect.none
           , Cmd.none
           )

        NoOp ->
            ( model
            , Nats.Effect.none
            , Cmd.none
            )

        _ ->
            ( model
            , Nats.Effect.none
            , Cmd.none
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
            case model.serverInfo of
                Just _ ->
                    True

                Nothing ->
                    False
    in
    { title = "Elm Nats Demo"
    , body =
        [ scaffolding <|
            [ [ h4 [] [ text "Here is what we know about the NATS server" ]
              , case model.serverInfo of
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


main : Program { now : Int } Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = updateWrapper
        , subscriptions = subscriptions
        }



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Nats.subscriptions natsConfig model.nats