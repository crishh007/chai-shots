const mongoose = require("mongoose");

const seriesSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String
  },
  category: {
    type: String
  }
}, { timestamps: true });

module.exports = mongoose.model("Series", seriesSchema);