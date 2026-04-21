const http = require('http');
const query = process.argv[2] || 'test';
http.get('http://localhost:5000/api/search?query=' + encodeURIComponent(query), (resp) => {
  let data = '';
  resp.on('data', (chunk) => { data += chunk; });
  resp.on('end', () => { console.log(data); });
}).on("error", (err) => {
  console.log("Error: " + err.message);
});
