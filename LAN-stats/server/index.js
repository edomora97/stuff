var color = require('colors');
var express = require('express');
var app = express();
var server = app.listen(3000);
var io = require('socket.io').listen(server);
var client = require('./client.js');


app.use(express.static(__dirname + '/public'));

io.on("connect", function(socket) {
    client.client(io, socket);
});

app.get('/cache', function(req, res) {
    res.json(client.cache);
});

console.log("Server listening on port 3000".rainbow);
