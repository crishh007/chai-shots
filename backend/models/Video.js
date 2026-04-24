const mongoose = require("mongoose");

const videoSchema = new mongoose.Schema({
  title: String,
  description: String,
  videoUrl: String,
  thumbnailUrl: String,
  genre: String,
  views: { type: Number, default: 0 },
  likes: { type: Number, default: 0 }
}, { timestamps: true });

module.exports = mongoose.model("Video", videoSchema);