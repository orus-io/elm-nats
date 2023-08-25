function setupNatsPorts(app) {
    let sockets = {};

    app.ports.natsOpen.subscribe(function(data) {
        const sid = data[0]
        const url = data[1]

        try {
            let socket = new WebSocket(url);

            socket.onopen = function(event) {
                sockets[sid] = socket;
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
                    app.ports.natsOnMessage.send(
                        { sid: sid
                        , message : reader.result
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

        if (socket) {
            console.log("sending", data.message);
            socket.send(data.message);
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
