const http = require('http');
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World from Docker multi-stage build\n');
});

server.listen(port, () => {
  console.log(`Multi-stage app listening on port ${port}`);
});
