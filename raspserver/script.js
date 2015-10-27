function getCPULoad() {
  $.ajax({
    url: "load",
    dataType: "json",
    success: function(data) {
      $("#load-1m").text(Math.floor(data.load1m*100)+"%");
      $("#load-5m").text(Math.floor(data.load5m*100)+"%");
      $("#load-15m").text(Math.floor(data.load15m*100)+"%");
    },
    error: function(data) {
      console.error(data);
    }
  });
}

function getTime() {
  $.ajax({
    url: "time",
    dataType: "json",
    success: function(data) {
      $("#time").text(data.time);
    },
    error: function(data) {
      console.error(data);
    }
  });
}

function getUptime() {
  $.ajax({
    url: "uptime",
    dataType: "json",
    success: function(data) {
      $("#uptime").text(data.uptime);
    },
    error: function(data) {
      console.error(data);
    }
  });
}

function getUsers() {
  $.ajax({
    url: "users",
    dataType: "json",
    success: function(data) {
      var table = $("#users tbody");
      table.empty();
      for (i in data) {
        var usr = data[i];
        var row = $("<tr>");
        row.append($("<td>").text(usr.user));
        row.append($("<td>").text(usr.tty));
        row.append($("<td>").text(usr.from));
        row.append($("<td>").text(usr.when));
        row.append($("<td>").text(usr.idle));
        row.append($("<td>").text(usr.jcpu));
        row.append($("<td>").text(usr.pcpu));
        row.append($("<td>").text(usr.what.join(' ')));
        table.append(row);
      }
    },
    error: function(data) {
      console.error(data);
    }
  });
}

function getProcesses() {
  $.ajax({
    url: "process",
    dataType: "json",
    success: function(data) {
      var table = $("#process tbody");
      table.empty();
      for (i in data) {
        var usr = data[i];
        var row = $("<tr>");
        row.append($("<td>").text(usr.user));
        row.append($("<td>").text(usr.pid));
        row.append($("<td>").text(usr.cpu));
        row.append($("<td>").text(usr.mem));
        row.append($("<td>").text(usr.tty));
        row.append($("<td>").text(usr.start));
        row.append($("<td>").text(usr.time));
        row.append($("<td>").text(usr.command.join(' ')));
        table.append(row);
      }
    },
    error: function(data) {
      console.error(data);
    }
  });
}


function getDisk() {
  $.ajax({
    url: "disk",
    dataType: "json",
    success: function(data) {
      var table = $("#disk tbody");
      table.empty();
      for (i in data) {
        var usr = data[i];
        var row = $("<tr>");
        row.append($("<td>").text(usr.device));
        row.append($("<td>").text(usr.size));
        row.append($("<td>").text(usr.used));
        row.append($("<td>").text(usr.free));
        row.append($("<td>").text(usr.perc));
        row.append($("<td>").text(usr.mount));
        table.append(row);
      }
    },
    error: function(data) {
      console.error(data);
    }
  });
}
