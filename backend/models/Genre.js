const mongoose = require("mongoose");

const genreSchema = new mongoose.Schema({
  name: String,
  image: String
});

module.exports = mongoose.model("Genre", genreSchema);