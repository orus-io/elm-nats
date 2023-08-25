# elm-nats

This library is a pure Elm implementation of the NATS client protocol on top
a websocket.

## Prerequisites

A running nats-server, with websockets enabled (see
[WebSocket Configuration Example](https://docs.nats.io/running-a-nats-service/configuration/websocket/websocket_conf))

## Setup

NATS subscriptions handling is a stateful business, which is all done by the
Nats module. You need to wire it into your application.


1. Import the Nats module

    ```elm
    import Nats
    import Nats.Config
    import Nats.Effect
    import Nats.PortsAPI
    import Nats.Protocol
    import Nats.Socket
    import Nats.Sub
    ```

1. Add a state for each of the nats connection your application handles to your
   top-level model, or at least one that contains all the components that uses
   the Nats API.

   ```elm
   type alias Model =
       { nats: Nats.State Msg
       -- ...
       }
   ```

1. Add a NatsMsg tag to your Msg type:

   ```elm
   type Msg
       = ...
       | NatsMsg Nats.Msg
   ```

1. Setup the ports and the configuration:

   ```elm
   port natsOpen : ( String, String ) -> Cmd msg
   port natsClose : String -> Cmd msg
   port natsOnOpen : (String -> msg) -> Sub msg
   port natsOnClose : (String -> msg) -> Sub msg
   port natsOnError : ({ sid : String, message : String } -> msg) -> Sub msg
   port natsOnMessage : (Nats.PortsAPI.Message -> msg) -> Sub msg
   port natsSend : Nats.PortsAPI.Message -> Cmd msg

   natsConfig : Nats.Config.Config Msg
   natsConfig =
       Nats.Config.init NatsMsg
           { open = natsOpen
           , close = natsClose
           , onOpen = natsOnOpen
           , onClose = natsOnClose
           , onError = natsOnError
           , onMessage = natsOnMessage
           , send = natsSend
           }
   ```

1. Initialize the State.

   ```elm
   init { flags | now : Int }=
       { nats = Nats.init now (Time.millisToPosix now)
       }
   ```

   If you have credentials or a client name to send as CONNECT options,
   use setAuthToken, setUserPass and/or setName:

   ```elm
   init =
       { nats =
           Nats.init
               |> Nats.setAuthToken "A token"
               |> Nats.setName "My client name"
       }
   ```

1. Connect nats to the ports :

   ```elm
   subscriptions : Model -> Sub Msg
   subscriptions =
       Nats.connect natsConfig model.nats
   ```

1. Define the top-level nats subscriptions:

   ```elm
   natsSubscriptions : Model -> Nats.Sub
   natsSubscriptions model =
       Nats.Sub.none
   ```

1. Have your update function returns nats effect along with the regular Cmd, and
   wrap it to handle them:

   ```elm
   wrappedUpdate : Msg -> Model -> ( Model, Cmd Msg )
   wrappedUpdate msg model =
       let
           ( newModel, natsEffect, cmd ) =
               update msg model
        
           ( nats, natsCmd ) =
               Nats.applyEffectAndSub natsConfig natsEffect (natsSubscriptions model) newModel.nats
       in
       ( { newModel | nats = nats }
       , Cmd.batch [ cmd, natsCmd ]
       )

   update : Msg -> Model -> ( Model, Nats.Effect Msg, Cmd Msg)
   update msg model =
       ( model, Nats.Effect.none, Cmd.none )
   ```

1. At last, setup the ports on the javascript side, by using the 'js/natsports.js' file:

   ```html
   <html>
   <head>
    <meta charset="UTF-8">
    <script src="main.js"></script>
    <script src="natsports.js"></script>
   </head>
   <body>
    <script>
        var app = Elm.Main.init( { flags: { now: Date.now() } } );
        setupNatsPorts(app);
    </script>
   </body>
   </html>
   ```

## Usage

### Open a connection

```elm

    ( model
    , Nats.Socket.new "0" "ws://localhost:8087"
        |> Nats.Socket.withUserPass "user" "password"
        |> Nats.open
    , Cmd.none
    )

```

### Publishing

In update, use publish to generate the right Effect:

```elm

    ( model
    , Nats.publish "subject1" "Hello world!"
    , Cmd.none
    )

```

### Subscribing

1. Define a Msg tag for receiving messages

   ```elm

   type Msg
       = ReceiveSubject1 Nats.Protocol.Message
   ```

1. Add the subscriptions to the "natsSubscriptions" function:

   ```elm
   natsSubscriptions model =
       Nats.subscribe "subject1" ReceiveSubject1
   ```

### Request

1. Define a Msg tag for receiving the response

   ```elm

   type Msg
       = ReceiveResponse (Result Nats.Errors.Timeout Nats.Protocol.Message)
   ```

1. Send a request from your update function

   ```elm
   ( model
   , Nats.request "subject1" "message" ReceiveResponse
   , Cmd.none
   )
   ```
