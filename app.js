const http = require('http');
const os = require('os');

console.log("Node app starting...");

var handler = function(request, response) {
  console.log("Received request from " + request.connection.remoteAddress);
  response.writeHead(200);
  response.end("You've hit v1 running on: " + os.hostname() + "\n");
};

var www = http.createServer(handler);
www.listen(8080);