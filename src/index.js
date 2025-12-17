const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
  res.send('<h1>DevSecOps Pipeline Successful!</h1><p>Image is Secure & Deployed.</p>');
});

app.listen(port, () => {
  console.log(`App running at http://localhost:${port}`);
});
