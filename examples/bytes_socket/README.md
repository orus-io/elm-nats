# elm-nats demo

Small demonstration app for elm-nats.

## Setup

Compile the example:

```bash
cd example
elm-make Main.elm --output main.js --debug
```

Install a nats-server in a go-ready environment:

```bash
go install github.com/nats-io/nats-server/v2@latest
```

Run nats-server:

```bash
nats-server -c server.conf
```

## Run

Open `example/index.html` in you favorite browser.

## Bytes ports

If you use the lamdera compiler, you can choose to enable bytes ports by
replacing NatsPorts by NatsBinaryPorts in src/Main.elm.
The bytes will then be passed through ports without base64 encoding/decoding.
