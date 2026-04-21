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
    const { title, seriesId } = req.body;

    const videoUrl = req.file.path;

    const episode = new Episode({
      title,
      seriesId,
      videoUrl
    });

    await episode.save();

    res.json({
      message: "Episode uploaded successfully",
      episode
    });

  } catch (error) {
    res.status(500).json({
      message: "Upload failed",
      error: error.message
    });
  }
};

// ✅ GET ALL EPISODES (optional)
exports.getAllEpisodes = async (req, res) => {
  try {
    const episodes = await Episode.find();
    res.json(episodes);
  } catch (error) {
    res.status(500).json({ message: "Error fetching episodes" });
  }
};

// ✅ GET EPISODES BY SERIES (IMPORTANT)
exports.getEpisodesBySeries = async (req, res) => {
  try {
    const { seriesId } = req.params;

    const episodes = await Episode.find({ seriesId });

    res.json(episodes);
  } catch (error) {
    res.status(500).json({ message: "Error fetching episodes" });
  }
};

// ✅ GET SINGLE EPISODE
exports.getEpisodeById = async (req, res) => {
  try {
    const { id } = req.params;

    const episode = await Episode.findById(id);

    res.json(episode);
  } catch (error) {
    res.status(500).json({ message: "Error fetching episode" });
  }
};

// ✅ LIKE / SAVE EPISODE
exports.saveEpisode = async (req, res) => {
  try {
    const { episodeId } = req.body;

    await Episode.findByIdAndUpdate(episodeId, {
      $inc: { likes: 1 }
    });

    res.json({ message: "Episode liked ❤️" });
  } catch (error) {
    res.status(500).json({ message: "Error liking episode" });
  }
};

// ✅ CLAP FEATURE
exports.clapEpisode = async (req, res) => {
  try {
    const { episodeId } = req.body;

    await Episode.findByIdAndUpdate(episodeId, {
      $inc: { claps: 1 }
    });

    res.json({ message: "Clapped 👏" });
  } catch (error) {
    res.status(500).json({ message: "Error clapping" });
  }
};