const http = require('http');
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World from Node.js!\n');
});

server.listen(port, () => {
  console.log(`Node.js server listening on port ${port}`);
});
