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

1. Add a NatsMsg tag to your Msg type:

   ```elm
   type Msg
       = DoSomething
       | NatsMsg Nats.Msg
   ```

1. Add the following to your update function:

   ```elm
        NatsMsg natsMsg ->
            let
                ( nats, natsCmd ) =
                    Nats.update natsMsg model.nats
            in
                { model
                    | nats = nats
                }
                    ! [ Cmd.map NatsMsg natsCmd ]
   ```

1. Define the top-level subscription

   ```elm
   subscriptions model =
       Nats.listen model.state NatsMsg
   ```

## Publishing

In update, use publish to generate the right Cmd:

```elm

model ! [ Nats.publish model.nats "subject1" "Hello world!" |> Cmd.map NatsMsg ]

```

## Subscribing

1. Initialize the subscriptions in init or update

   ```elm
   let
       ( nats, natsCmd ) =
           Nats.setupSubscription model.nats <|
               Nats.subscribe "subject1" ReceiveSubject1
   in
       { model
           | nats = nats
       }
           ! [ Cmd.map NatsMsg natsCmd ]
   ```
