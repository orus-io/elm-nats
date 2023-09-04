# elm-nats

[NATS](https://nats.io) is a simple, secure and performant communications
system for digital systems, services and devices.

This library is a pure Elm implementation of the NATS client protocol on top
a websocket.

## Prerequisites

A running nats-server, with websockets enabled (see
[WebSocket Configuration Example](https://docs.nats.io/running-a-nats-service/configuration/websocket/websocket_conf))

## Demonstration apps

### Get a nats-server up

```
go install github.com/nats-io/nats-server/v2@latest 
cd examples/string_socket
nats-server -c server.conf
```

### Start the example app

```
cd examples/string_socket
elm-go -- src/Main.elm -o main.js
```

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

1. Add a global nats state, on your top-level application model, or Shared model.
   At this point you need to choose between Bytes and String sockets. The String
   socket will only be able to exchange String messages with the server.

   Using protobuf requires a Bytes socket.

   ```elm
   type alias Model =
       { nats: Nats.State String Msg
       -- ...
       }
   ```

1. Add a NatsMsg tag to your Msg type:

   ```elm
   type Msg
       = ...
       | NatsMsg Nats.Msg
   ```

1. Setup the ports and the configuration, with a message type consistent with
   your nats state:

   ```elm
   
   port natsSend : Nats.PortsAPI.Send String msg
   port natsReceive : Nats.PortsAPI.Receive String msg

   natsConfig : Nats.Config String String Msg
   natsConfig =
       Nats.Config.string NatsMsg
           { send = natsSend
           , receive = natsReceive
           }
   ```

1. Initialize the State.

   ```elm
   init { flags | now : Int } =
       { nats = Nats.init now (Time.millisToPosix now)
       }
   ```

1. Connect nats to the ports :

   ```elm
   subscriptions : Model -> Sub Msg
   subscriptions =
       Nats.subscriptions natsConfig model.nats
   ```

1. Define the top-level nats subscriptions:

   ```elm
   natsSubscriptions : Model -> Nats.Sub
   natsSubscriptions model =
       Nats.Sub.none
   ```

1. Have your update function(s) return nats effect along with the regular Cmd, and
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

Connect a socket is done with simple subscription:

```elm
   natsSubscriptions : Model -> Nats.Sub
   natsSubscriptions model =
       Nats.connect
           ( Nats.Socket.connectOptions
                 |> Nats.Socket.withUserPass "user" "password"
           )
           ( Nats.Socket.new "0" "ws://localhost:8087" )
```

The socket definition and connection options will generally be saved on the model


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
       = ReceiveSubject1 (Nats.Protocol.Message String)
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
       = ReceiveResponse (Result Nats.Errors.Timeout (Nats.Protocol.Message String))
   ```

1. Send a request from your update function

   ```elm
   ( model
   , Nats.request "subject1" "message" ReceiveResponse
   , Cmd.none
   )
   ```
