const WatchHistory = require("../models/WatchHistory");

// ✅ Add / Update history
exports.addHistory = async (req, res) => {
  const isMongoConnected = req.app.get('isMongoConnected')();

  if (!isMongoConnected) {
    console.log("Mock Add History triggered (No DB)");
    return res.json({
      message: "Watch history updated (MOCK MODE)",
      history: {
        userId: req.userId || "mock_user",
        episodeId: req.body.episodeId,
        watchedAt: new Date()
      }
    });
  }

  try {
    const { episodeId } = req.body;
// ... rest of original code ...

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
  const isMongoConnected = req.app.get('isMongoConnected')();

  if (!isMongoConnected) {
    console.log("Mock Get History triggered (No DB)");
    return res.json({
      message: "Watch history fetched (MOCK MODE)",
      history: [] // Return empty history in mock mode
    });
  }

  try {
    const history = await WatchHistory.find({ userId: req.userId })
// ... rest of original code ...
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