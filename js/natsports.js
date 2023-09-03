function setupNatsPorts(app) {
    let sockets = {};

    app.ports.natsOpen.subscribe(function(data) {
        const sid = data[0]
        const url = data[1]
        const mode = data[2]

        try {
            let socket = new WebSocket(url);

            socket.onopen = function(event) {
                sockets[sid] = {
                    socket: socket,
                    mode: mode
                };
                console.log("opened")
                app.ports.natsOnOpen.send(sid);
            };

            socket.onclose = function(event) {
                socket[sid] = undefined;
                app.ports.natsOnClose.send(sid);
            };

            socket.onerror = function(event) {
                socket[sid] = undefined;
                app.ports.natsOnError.send(
                    { sid : sid
                    , message : event.data
                    }
                );
            };

            socket.onmessage = function(event) {
                var reader = new FileReader();
                reader.onload = function () {
                    let message = reader.result
                    console.log("received", message)
                    if (mode == "binary") {
                        message = btoa(message)
                        console.log("b64", message)
                    }
                    app.ports.natsOnMessage.send(
                        { sid: sid
                        , ack : null
                        , message : message
                        }
                    );
                };
                reader.readAsText(event.data);
            };
        } catch (exception) {
            console.error(exception);
        }
    });

    app.ports.natsSend.subscribe(function(data) {
        const sid = data.sid;

        const socket = sockets[sid];
        console.log("natsSend", sid, socket, data.ack);

        if (socket) {
            let message = data.message;
            if (socket.mode == "binary") {
                message = atob(message)
            }
            console.log("sending", message);
            socket.socket.send(message);
            if (data.ack !== null) {
                app.ports.natsOnAck.send(
                    { sid : sid
                    , ack : data.ack
                    }
                )
            }
        }
    });

    app.ports.natsClose.subscribe(function(data) {
        const sid = data;

        const socket = sockets[sid];

        if (socket) {
            socket.Close();
        }
    });
}
