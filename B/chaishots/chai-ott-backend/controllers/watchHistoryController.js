const WatchHistory = require("../models/WatchHistory");

// ✅ Add / Update history
exports.addHistory = async (req, res) => {
  try {
    const { episodeId } = req.body;

    if (!episodeId) {
      return res.status(400).json({
        message: "episodeId is required"
      });
    }

    const history = await WatchHistory.findOneAndUpdate(
      { userId: req.userId, episodeId },
      { watchedAt: new Date() },
      { upsert: true, new: true }
    );

    res.json({
      message: "Watch history updated",
      history
    });

  } catch (error) {
    res.status(500).json({
      message: "Error adding history",
      error: error.message
    });
  }
};

// ✅ Get history
exports.getHistory = async (req, res) => {
  try {
    const history = await WatchHistory.find({ userId: req.userId })
      .populate("episodeId")
      .sort({ watchedAt: -1 });

    res.json({
      message: "Watch history fetched",
      history
    });

  } catch (error) {
    res.status(500).json({
      message: "Error fetching history",
      error: error.message
    });
  }
};