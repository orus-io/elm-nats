function setupNatsPorts(app) {
    let sockets = {};

    app.ports.natsOpen.subscribe(function(socket) {
        const sid = socket.sid;

        try {
            let webSocket = new WebSocket(socket.url);
            if (socket.debug) {
                console.log("socket", sid, "connecting to", socket.url, "in", socket.mode, "mode")
            }

            webSocket.onopen = function(event) {
                sockets[sid] = {
                    socket: webSocket,
                    mode: socket.mode,
                    debug: socket.debug
                };
                if (socket.debug) {
                    console.log("socket", sid, "onopen") 
                }
                app.ports.natsOnOpen.send(sid);
            };

            webSocket.onclose = function(event) {
                socket[sid] = undefined;
                if (socket.debug) {
                    console.log("socket", sid, "onclose") 
                }
                app.ports.natsOnClose.send(sid);
            };

            webSocket.onerror = function(event) {
                socket[sid] = undefined;
                if (socket.debug) {
                    console.log("socket", sid, "onerror: ", event.data) 
                }
                app.ports.natsOnError.send(
                    { sid : sid
                    , message : event.data
                    }
                );
            };

            webSocket.onmessage = function(event) {
                var reader = new FileReader();
                reader.onload = function () {
                    let message = reader.result
                    if (socket.debug) {
                        console.log("socket", sid, "received", message)
                    }
                    if (socket.mode == "binary") {
                        message = btoa(message)
                    }
                    app.ports.natsOnMessage.send(
                        { sid: sid
                        , ack : null
                        , message : message
                        }
                    );
                };
                if (socket.mode == "binary") {
                    reader.readAsBinaryString(event.data)
                } else {
                    reader.readAsText(event.data);
                }
            };
        } catch (exception) {
            console.error(exception);
        }
    });

    app.ports.natsSend.subscribe(function(data) {
        const sid = data.sid;

        const socket = sockets[sid];

        if (socket) {
            let message = data.message;
            if (socket.mode == "binary") {
                message = atob(message)
            }
            if(socket.debug) {
                console.log("socket", sid, "sending", message);
            }
            socket.socket.send(message);
            if (data.ack !== null) {
                if(socket.debug) {
                    console.log("socket", sid, "returning ack", data.ack);
                }
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
