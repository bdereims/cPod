"use strict"
const http = require('http');
const os = require('os');

let hostname = os.hostname();
var ips = require('child_process').execSync("ifconfig | grep inet | grep -v inet6 | awk '{gsub(/addr:/,\"\");print $2}'").toString().trim().split("\n");

http.createServer((req, res) => {  
  res.end('World from ['+ips+']');
}).listen(5000);
