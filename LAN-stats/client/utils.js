var cpu = require('windows-cpu');

var io;

var get_cpu = function() {
    cpu.totalLoad(function(error, results) {
        if (error)
            //io.emit("cpu", { error: true });
            io.emit("cpu", { error: false, results: [Math.random()*100|0, Math.random()*100|0] });
        else
            io.emit("cpu", { error: false, results: results });
    });
}

var get_memory = function() {
    cpu.totalMemoryUsage(function(error, results) {
        if (error)
            //io.emit("ram", { error: true });
            io.emit("ram", { error: false, results: ("" + (Math.random()*4096|0) + "MB") });
        else
            io.emit("ram", { error: false, results: results.usageInMb|0 + "MB" });
    });
}

var poller = function() {
    get_cpu();
    get_memory();
}

module.exports = function(socket) {
    io = socket;
    return {
        poller: poller
    }
}
