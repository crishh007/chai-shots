const mongoose = require("mongoose");

const episodeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  seriesId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Series"
  },
  videoUrl: {
    type: String
  }
}, { timestamps: true });

module.exports = mongoose.model("Episode", episodeSchema);