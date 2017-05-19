# elm-nats

This library is a pure Elm implementation of the NATS client protocol on top
a websocket.

It clearly an alpha version of what I have in mind, which means the API is likely
to change.

## Prerequisites

1. A running gnatsd server
1. A running [nats-websocket-gw](https://github.com/orus.io/nats-websocket-gw), probably
   with the '--no-origin-check' for tests. For production use, I recommend embedding
   nats-websocket-gw as a library and not use the binary directly.

## Setup

NATS subscriptions handling is a stateful business, which is all done by the
Nats module. You need to wire it into your application though.

1. Import the Nats module

    ```elm
    import Nats
    import Nats.Protocol
    import Nats.Sub as NatsSub
    ```

1. Add a state to your top-level model, or at least one that contains all
   the components that uses the Nats API.

    ```elm
    type alias Model =
        { nats: Nats.State Msg
        -- ...
        }
    ```

1. Initialize the State with the websocket url. If working locally with
   nats-websocket-gw, it should be "ws://localhost:8910/nats":

    ```elm
    init =
        { nats: Nats.init "WEBSOCKET_URL"
        }
    ```

1. Define a "mergeNats" function that can post-process your model and nats
   subscriptions and commands to give you a final state and commands:

   ```elm
   mergeNats : ( Model, Nats.NatsCmd Msg, Cmd Msg ) -> ( Model, Cmd Msg )
   mergeNats ( model, natsCmd, cmd ) =
       let
           ( natsState, extraCmd ) =
               Nats.merge model.nats (natsSubscriptions model) natsCmd
       in
           { model
               | nats = natsState
           }
               ! [ cmd, Cmd.map NatsMsg extraCmd ]
   ```

1. Add a NatsMsg tag to your Msg type:

   ```elm
   type Msg
       = DoSomething
       | NatsMsg Nats.Msg
   ```

1. Change your update function to apply mergeNats after the classic 'case msg of',
   which now returns ( model, natsCmd, cmd ) instead of ( model, cmd ):

   ```elm
   update : Msg -> Model -> ( Model, Cmd Msg )
   update msg model =
       mergeNats
           (case msg of
               NoOp ->
                   
                   ( model, Nats.none, Cmd.none )
               NatsMsg natsMsg ->
                   let
                       ( nats, natsCmd ) =
                           Nats.update natsMsg model.nats
                   in
                       ( { model
                           | nats = nats
                         }
                       , Nats.none
                       , Cmd.map NatsMsg natsCmd
                       )
           )
                   
   ```

1. Define the top-level subscription and nats subscriptions:

   ```elm
   subscriptions model =
       Nats.listen model.state NatsMsg

   natsSubscriptions model =
       NatsSub.none
   ```

## Publishing

In update, use publish to generate the right Cmd:

```elm

    ( model
    , Nats.publish model.nats "subject1" "Hello world!"
    , Cmd.none
    )

```

## Subscribing

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

# Request

1. Define a Msg tag for receiving the response

   ```elm

   type Msg
       = ReceiveResponse Nats.Protocol.Message
   ```

1. Send a request from your update function

   ```elm
   ( model
   , Nats.request "subject1" ReceiveResponse
   , Cmd.none
   )
   ```
