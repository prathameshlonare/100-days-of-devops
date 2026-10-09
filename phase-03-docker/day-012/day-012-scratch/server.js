const http = require('http');
const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('day12 voting-frontend running\n');
});
// 0.0.0.0 is mandatory inside containers. 127.0.0.1 would listen only on container loopback and -p would still refuse.
server.listen(3000, '0.0.0.0', () => console.log('listening on 3000 pid=' + process.pid));