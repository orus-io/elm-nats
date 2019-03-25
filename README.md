# elm-nats

This library is a pure Elm implementation of the NATS client protocol on top
a websocket.

It works by adding new Nats.Cmd and Nats.Sub to TEA, and merging them into
classic Cmd and Sub in update and subscriptions.

It clearly is an alpha version, which means the API is likely to change.

## Prerequisites

1. A running gnatsd server
1. A running [nats-websocket-gw](https://github.com/orus.io/nats-websocket-gw), probably
   with the '--no-origin-check' for tests. For production use, I recommend embedding
   nats-websocket-gw as a library and not use the binary directly.

## Setup

NATS subscriptions handling is a stateful business, which is all done by the
Nats module. You need to wire it into your application.

1. Import the Nats module

    ```elm
    import Nats
    import Nats.Protocol
    import Nats.Cmd as NatsCmd
    import Nats.Sub as NatsSub
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
       = DoSomething
       | NatsMsg Nats.Msg
   ```

1. Initialize the State.

    ```elm
    init =
        { nats = Nats.init
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


1. Define the top-level subscription and nats subscriptions:

   ```elm
   subscriptions model =
       Sub.batch
           -- natsReceive is a subscription that receives all the messages
           -- from the nats connection.
           [ natsReceive Nats.receive
           , Nats.listen model.state
           ]
           |> Sub.map NatsMsg

   natsSubscriptions model =
       NatsSub.none
   ```


1. Define a handleNatsSideEffects that will translate Nats side effects into
   concrete commands or messages:

   ```elm
   handleNatsSideEffects : List (Nats.SideEffect Msg) -> Model -> ( Model, Cmd Msg )
   handleNatsSideEffects =
       Nats.handleNatsSideEffects
           { update = update
           , tagger = NatsMsg
           {- natsSend is a (String -> Cmd msg), that results in sending the
              given message to the nats connection.
           -}
           , natsSend = natsSend
           }
   ```


1. Define a "mergeNats" function that can post-process your model and nats
   subscriptions and commands to give you a final state and commands:

   ```elm
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
            |> addCmd cmd  -- addCmd is imported from Janiczek/cmd-extra
   ```


1. Change your update function to apply mergeNats after the classic 'case msg of',
   which now returns ( Model, NatsCmd.Cmd Msg, Cmd Msg) instead of ( Model, Cmd Msg ):

   ```elm
   update : Msg -> Model -> ( Model, Cmd Msg )
   update msg model =
       mergeNats
           (case msg of
               NoOp ->

                   ( model, NatsCmd.none, Cmd.none )
               NatsMsg natsMsg ->
                   let
                       ( nats, natsCmd ) =
                           Nats.update natsMsg model.nats
                   in
                       ( { model
                           | nats = nats
                         }
                       , NatsCmd.none
                       , natsCmd
                       )
           )

   ```

1. Plug an actual websocket connection and the Nats state, for example with
   ports:

   ```elm
    port natsSend : String -> Cmd msg


    port natsReceive : (String -> msg) -> Sub msg
   ```

   ```html
   <script>
       var app = Elm.Main.init();

       var socket = null;
       try {
           socket = new WebSocket("ws://localhost:8910/nats");

       } catch (exception) {
           console.error(exception);
       }

       if (socket !== null) {
           var sendToNats = function(data) {
               socket.send(data);
           };
           socket.onerror = function(error) {
               console.error(error);
           };

           socket.onopen = function(event) {
               app.ports.natsSend.subscribe(sendToNats);

               this.onclose = function(event) {
                   app.ports.natsSend.unsubscribe(sendToNats);
               };

               this.onmessage = function(event) {
                   app.ports.natsReceive.send(event.data);
               };
           };
       }
   </script>
    ```

## Usage

### Publishing

In update, use publish to generate the right Cmd:

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

#### Multiple subscriptions to the same subject

natsSubscriptions are recognized by their subject only,
which means several subscriptions on the same subject
will collide and only one of them will be honored.

To avoid this problem, Elm-Nats allow you to tag the
subscriptions subject by adding a '#' followed by
any string you like, so it can sort them out.

Only the part before the '#' will be sent in the SUB command
to the NATS server.

In the following example, both subscriptions are on the
"subject1" subject:

```elm
natsSubscriptions model =
    Nats.Sub.batch
        [ Nats.subscribe "subject1#1" ReceiveSubject1
        , Nats.subscribe "subject1#2" ReceiveAlsoSubject1
        ]
```

See the SubComp in example, it can define any number of
subscriptions on the same subject.

### Request

1. Define a Msg tag for receiving the response

   ```elm

   type Msg
       = ReceiveResponse (Result Nats.Errors.Timeout Nats.Protocol.Message)
   ```

1. Send a request from your update function

   ```elm
   ( model
   , Nats.request "subject1" ReceiveResponse
   , Cmd.none
   )
   ```
