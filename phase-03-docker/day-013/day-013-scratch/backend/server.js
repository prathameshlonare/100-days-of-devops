const http = require('http');
const srv = http.createServer((req, res) => {
    if (req.url === '/api/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', service: 'voting-backend' }));
        return;
    }
    res.writeHead(404); res.end();
});
// 0.0.0.0 so bridge traffic via eth0 is accepted, not just container loopback.
srv.listen(4000, '0.0.0.0', () => console.log('backend listening 4000'));