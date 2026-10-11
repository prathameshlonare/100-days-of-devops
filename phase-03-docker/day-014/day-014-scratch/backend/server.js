const http = require('http');
const fs = require('fs');
const API_PORT = 4000;
const FILE = '/data/votes.txt';
try { fs.mkdirSync('/data', { recursive: true }); } catch (e) { }
const srv = http.createServer((req, res) => {
    if (req.url === '/api/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok' })); return;
    }
    if (req.url.startsWith('/api/vote')) {
        fs.appendFileSync(FILE, 'vote\n');
        const n = fs.readFileSync(FILE, 'utf8').trim().split('\n').length;
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ votes: n })); return;
    }
    res.writeHead(404); res.end();
});
srv.listen(API_PORT, '0.0.0.0', () => console.log('backend 4000 data=' + FILE));