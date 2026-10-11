const http = require('http');
const API = process.env.API_URL || 'http://backend:4000';
const srv = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('day14 frontend api=' + API + '\n');
});
srv.listen(3000, '0.0.0.0', () => console.log('frontend 3000 api=' + API));