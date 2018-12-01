// History
// 2018-11-19  Init
// 2018-12-01  CEC name support

// Dependencies
var fs = require("fs");
var app = require("express")();
var server = require("http").Server(app);
var serveStatic = require("serve-static");
var io = require("socket.io")(server);
var NodeCEC = require("nodecec");

// Constants
const HTTP_PORT = 80;
const HTTP_FOLDER = "/var/www/";

// CEC
var cecName = "";
var configFileContent = fs.readFileSync("/boot/config.txt", "utf8");
var regex = /(^cec_osd_name\s*=\s*)\w*/gm;
var match = regex.exec(configFileContent);
if (match) {
  cecName = match[0].replace(match[1], "");
}

var cec = new NodeCEC();
if (cecName) {
  cec.start(cecName);
} else {
  cec.start();
}

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