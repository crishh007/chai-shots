const Episode = require("../models/Episode");

exports.createEpisode = async (req, res) => {
  try {
    const episode = new Episode(req.body);
    await episode.save();
    res.json({ message: "Episode created", episode });
  } catch (error) {
    res.status(500).json({ message: "Error creating episode" });
  }
};

exports.uploadEpisode = async (req, res) => {
  try {
    console.log("UPLOAD BODY:", req.body);
    const { title, seriesId, isDiscover, isPremium } = req.body;
    const videoUrl = req.file.path;
    const episode = new Episode({
      title,
      seriesId,
      videoUrl,
      isDiscover: String(isDiscover).toLowerCase() === 'true',
      isPremium: String(isPremium).toLowerCase() === 'true'
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

exports.getEpisodes = async (req, res) => {
  try {
    const episodes = await Episode.find();
    res.json(episodes);
  } catch (error) {
    res.status(500).json({ message: "Error fetching episodes" });
  }
};

exports.getEpisodesBySeries = async (req, res) => {
  try {
    const episodes = await Episode.find({ seriesId: req.params.seriesId });
    res.json(episodes);
  } catch (error) {
    res.status(500).json({ message: "Error fetching episodes for series" });
  }
};

exports.deleteEpisode = async (req, res) => {
  try {
    await Episode.findByIdAndDelete(req.params.id);
    res.json({ message: "Episode deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting episode" });
  }
};