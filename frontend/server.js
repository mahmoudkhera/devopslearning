const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const API_URL = process.env.API_URL || 'http://localhost:4000';

const html = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8')
  .replace('window.API_URL || \'http://localhost:4000\'', `'${API_URL}'`);

http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(html);
}).listen(PORT, () => {
  console.log(`Frontend running on http://localhost:${PORT}`);
  console.log(`Pointing to API: ${API_URL}`);
});