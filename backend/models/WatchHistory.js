const mongoose = require("mongoose");

const watchHistorySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  episodeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Episode",
    required: true
  },
  watchedAt: {
    type: Date,
    default: Date.now
  }
});

// جلوگیری duplicate entries
watchHistorySchema.index({ userId: 1, episodeId: 1 }, { unique: true });

module.exports = mongoose.model("WatchHistory", watchHistorySchema);