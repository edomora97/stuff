var socket = require('socket.io-client')('http://localhost:3000');
var utils = require("./utils.js")(socket);


socket.on('connect', function() {
    console.log("Connected to server");
    socket.emit("login", true);
    setInterval(utils.poller, 1000);
});
socket.on('disconnect', function() {
    console.log("Disconnected from server");
});

socket.on('ping', function(code) {
    socket.emit('pong', code);
});
