function setupNatsPorts(app) {
    let sockets = {};

    app.ports.natsSend.subscribe(function(command) {
        if (command.close) {
            const sid = command.close;

            const socket = sockets[sid];

            if (socket) {
                socket.Close();
            }
        } else if (command.send) {
            const sid = command.send.sid;

            const socket = sockets[sid];

            if (socket) {
                let message = command.send.message;
                if (socket.mode == "binary") {
                    message = atob(message)
                }
                if(socket.debug) {
                    console.log("socket", sid, "sending", message);
                }
                socket.socket.send(message);
                if (command.send.ack !== null) {
                    if(socket.debug) {
                        console.log("socket", sid, "returning ack", command.send.ack);
                    }
                    app.ports.natsReceive.send(
                        { ack :
                            { sid : sid
                            , ack : command.send.ack
                            }
                        , open : null
                        , close : null
                        , error : null
                        , message : null
                        }
                    )
                }
            }
        } else if (command.open) {
            const socket = command.open;
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
                    app.ports.natsReceive.send(
                        { ack : null
                        , open : sid
                        , close : null
                        , error : null
                        , message : null
                        }
                    );
                };

                webSocket.onclose = function(event) {
                    socket[sid] = undefined;
                    if (socket.debug) {
                        console.log("socket", sid, "onclose") 
                    }
                    app.ports.natsReceive.send(
                        { ack : null
                        , open : null
                        , close : sid
                        , error : null
                        , message : null
                        }
                    );
                };

                webSocket.onerror = function(event) {
                    socket[sid] = undefined;
                    if (socket.debug) {
                        console.log("socket", sid, "onerror: ", event) 
                    }
                    app.ports.natsReceive.send(
                        { ack : null
                        , open : null
                        , close : null
                        , error :
                            { sid : sid
                            , message : JSON.stringify(event)
                            }
                        , message : null
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
                        } else if (socket.mode == "binaryPort") {
                            message = new DataView(message)
                        }
                        app.ports.natsReceive.send(
                            { ack : null
                            , open : null
                            , close : null
                            , error : null
                            , message :
                                { sid: sid
                                , ack : null
                                , message : message
                                }
                            }
                        );
                    };
                    if (socket.mode == "text") {
                        reader.readAsText(event.data);
                    } else if (socket.mode == "binary") {
                        reader.readAsBinaryString(event.data);
                    } else {
                        reader.readAsArrayBuffer(event.data)
                    }
                };
            } catch (exception) {
                console.error(exception);
            }
        }
    });
}
