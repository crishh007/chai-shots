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
  },
  thumbnail: {
    type: String
  },
  videoUrl: {
    type: String
  },
  isTrending: {
    type: Boolean,
    default: false
  },
  isNewRelease: {
    type: Boolean,
    default: false
  }
}, { timestamps: true });

module.exports = mongoose.model("Series", seriesSchema);