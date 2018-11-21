// History
// 2018-11-19	Init

// Dependencies
var app = require("express")();
var server = require("http").Server(app);
var serveStatic = require("serve-static");
var io = require("socket.io")(server);
var NodeCEC = require("nodecec");

// Constants
const HTTP_PORT = 80;
const HTTP_FOLDER = "/var/www/";

// CEC
var cec = new NodeCEC();
cec.start();
cec.on("ready", function (data) {
  console.log("cec: ready");
});

// SOCKET.IO
io.on("connection", function (socket) {
  console.log("io: new client connection from %s", socket.handshake.address);

  socket.on("disconnect", function () {
    console.log("io: client disconnected from %s", socket.handshake.address);
  });

  cec.on("key", function (data) {
    console.log("cec: got key %s", data.name);
    socket.emit("cec", data.name);
  });
});

// WEB SERVER
app.use("/", serveStatic(HTTP_FOLDER));

server.listen(HTTP_PORT, "localhost", function () {
  console.log("Server is now running on port: %s", HTTP_PORT);
});
