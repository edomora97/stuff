var fs = require('fs');
var colors = require('colors');


// Load clients list
var clients = JSON.parse(fs.readFileSync('clients.json', 'utf8'));
console.log("clients: ", clients);

// Custom logger function
var logError = function(str) { console.log(str.red); }
var log = function(str) { console.log(str.yellow); }

var cache = {};

var counter = 0;
var client = function(io, client) {
    var id = -1;
    var username = "";

    var logError = function(str) { console.log(username + " (" + id + "): " + str.red); }
    var log = function(str) { console.log(username + " (" + id + "): " + str.yellow); }

    client.on("login", function(data) {
        id = ++counter;
        username = clients[client.handshake.address] || ("moldavo anonimo " + id);

        log("Connected client from " + client.handshake.address + " as " + username);

        io.emit("client_connected", {
            id: id,
            ip: client.handshake.address,
            username: username
        });

        cache[id] = {
            username: username,
            ip: client.handshake.address,
            cpu: 0,
            ram: 0
        };
    });

    client.on("cpu", function(data) {
        if (data.error) logError("error on cpu...");
        else {
            io.emit("cpu_update", {
                id: id,
                data: data.results
            });
            cache[id].cpu = data.results;
        }
    });

    client.on("ram", function(data) {
        if (data.error) logError("error on ram...");
        else {
            io.emit("ram_update", {
                id: id,
                data: data.results
            });
            cache[id].ram = data.resutls;
        }
    });

    client.on("disconnect", function() {
        if (id != -1) {
            io.emit("client_disconnected", id);
            logError("Client disconnected");
            delete cache[id];
        }
    });

    var get_time = function() {
        var hrtime = process.hrtime();
        return ( hrtime[0] * 1000000 + hrtime[1] / 1000 ) / 1000;
    }

    var ping_code = -1;
    var start = 0;
    var ping = function() {
        if (ping_code != -1)
            logError("Ping timeout...");
        else if (id != -1)
            setTimeout(ping, 1000);
        start = get_time();
        ping_code = Math.random() * 1024 | 0;
        client.emit("ping", ping_code);
    }
    client.on("pong", function(res) {
        if (ping_code == res) {
            var end = get_time();
            cache[id].ping = ((end-start)|0)+"ms";
            log("ping: " + ((end-start)|0) + "ms");
            io.emit('ping_update', {
                id: id,
                data: ((end-start)|0)+"ms"
            });
        } else
            logError("BAD PING RESPONSE! " + ping_code + " " + res);
        ping_code = -1;
    });

    setTimeout(ping, 1000);
}

exports.client = client;
exports.cache = cache;
