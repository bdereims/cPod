"use strict"
const http = require('http');
const os = require('os');

let hostname = os.hostname();

http.createServer((req, res) => {  
  res.end('Hello, New Docker world from ' + hostname + '.\n');
}).listen(5000);
