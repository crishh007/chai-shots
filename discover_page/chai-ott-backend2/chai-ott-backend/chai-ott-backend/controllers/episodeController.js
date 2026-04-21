const Episode = require("../models/Episode");

// ✅ CREATE EPISODE
exports.createEpisode = async (req, res) => {
  try {
    const episode = new Episode(req.body);
    await episode.save();
    res.json({ message: "Episode created", episode });
  } catch (error) {
    res.status(500).json({ message: "Error creating episode" });
  }
};

// ✅ UPLOAD EPISODE (with file)
exports.uploadEpisode = async (req, res) => {
  try {
    const { title, seriesId, isPremium, isDiscover } = req.body;

    if (!req.file) {
      return res.status(400).json({ message: "No video file uploaded" });
    }

    const videoUrl = req.file.path;

    const episode = new Episode({
      title,
      seriesId,
      videoUrl,
      isPremium: isPremium === 'true' || isPremium === true,
      isDiscover: isDiscover === 'true' || isDiscover === true
    });

    await episode.save();

    res.json({
      message: "Episode uploaded successfully",
      episode
    });

  } catch (error) {
    console.error("Episode upload error:", error);
    res.status(500).json({
      message: "Upload failed",
      error: error.message
    });
  }
};

// ✅ GET ALL EPISODES
exports.getAllEpisodes = async (req, res) => {
  try {
    const episodes = await Episode.find().populate("seriesId");
    res.json(episodes);
  } catch (error) {
    res.status(500).json({ message: "Error fetching episodes" });
  }
};

// ✅ GET EPISODES BY SERIES
exports.getEpisodesBySeries = async (req, res) => {
  try {
    const { seriesId } = req.params;
    const episodes = await Episode.find({ seriesId }).sort({ createdAt: 1 }).populate('seriesId');
    
    // Format for frontend (ContentModel expectations)
    const formatted = episodes.map(ep => {
      const series = ep.seriesId || {};
      return {
        _id: ep._id,
        id: ep._id,
        title: ep.title,
        videoUrl: ep.videoUrl,
        thumbnailUrl: series.thumbnail || "https://picsum.photos/300/450?random=1",
        description: series.description || "",
        genre: series.category || "Drama",
        rating: "U/A 16+",
        type: "video"
      };
    });
    
    res.json(formatted);
  } catch (error) {
    console.error("Error in getEpisodesBySeries:", error);
    res.status(500).json({ message: "Error fetching episodes" });
  }
};

// ✅ GET SINGLE EPISODE
exports.getEpisodeById = async (req, res) => {
  try {
    const { id } = req.params;
    const episode = await Episode.findById(id).populate("seriesId");
    res.json(episode);
  } catch (error) {
    res.status(500).json({ message: "Error fetching episode" });
  }
};

// ✅ DELETE EPISODE
exports.deleteEpisode = async (req, res) => {
  try {
    const { id } = req.params;
    await Episode.findByIdAndDelete(id);
    res.json({ message: "Episode deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting episode" });
  }
};

// ✅ LIKE / SAVE EPISODE
exports.saveEpisode = async (req, res) => {
  try {
    const { episodeId } = req.body;
    await Episode.findByIdAndUpdate(episodeId, { $inc: { likes: 1 } });
    res.json({ message: "Episode liked ❤️" });
  } catch (error) {
    res.status(500).json({ message: "Error liking episode" });
  }
};

// ✅ CLAP FEATURE
exports.clapEpisode = async (req, res) => {
  try {
    const { episodeId } = req.body;
    await Episode.findByIdAndUpdate(episodeId, { $inc: { claps: 1 } });
    res.json({ message: "Clapped 👏" });
  } catch (error) {
    res.status(500).json({ message: "Error clapping" });
  }
};