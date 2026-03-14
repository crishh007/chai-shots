const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Chai Shots API Running");
});

app.listen(5000, () => {
  console.log("Server running on port 5000");
});