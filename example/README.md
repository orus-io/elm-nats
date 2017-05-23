# elm-nats demo

Small demonstration app for elm-nats.

## Setup

Compile the example:

```bash
cd example
elm-make Main.elm --output main.js --debug
```

Install a gnatsd and a nats-websocket-gw in a go-ready environment:

```bash
go get github.com/nats-io/gnatsd
go get github.com/orus-io/nats-websocket-gw
go install github.com/orus-io/nats-websocket-gw/cmd/nats-websocket-gw
```

Run gnatsd and nats-websocket-gw:

```bash
parallel -- gnatsd "nats-websocket-gw --no-origin-check"
```

## Run

Open `example/index.html` in you favorite browser.

