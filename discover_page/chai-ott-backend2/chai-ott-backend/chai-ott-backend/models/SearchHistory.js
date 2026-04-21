const mongoose = require("mongoose");

const searchSchema = new mongoose.Schema({
  userId: String,
  keyword: String,
  timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model("SearchHistory", searchSchema);