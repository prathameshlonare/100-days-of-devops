const http = require('http');
const API = process.env.API_URL || 'http://backend:4000';
function check() {
    http.get(API + '/api/health', (r) => {
        let b = ''; r.on('data', c => b += c); r.on('end', () => console.log('[API-CHECK] OK ' + b));
    }).on('error', (e) => console.log('[API-CHECK] FAIL ' + e.message + ' url=' + API));
}
const srv = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('day13 frontend running, api=' + API + '\n');
});
srv.listen(3000, '0.0.0.0', () => { console.log('frontend listening 3000 api=' + API); check(); });