const Episode = require("../models/Episode");
const Series = require("../models/Series");
const Content = require("../models/Content"); // Added this
const SearchHistory = require("../models/SearchHistory");
const Genre = require("../models/Genre");

// Helper to format DB objects to frontend expected format
const formatVideo = async (doc, type) => {
  if (type === 'series') {
    let videoUrl = doc.videoUrl;
    if (!videoUrl) {
      const firstEpisode = await Episode.findOne({ seriesId: doc._id }).sort({ createdAt: 1 });
      if (firstEpisode) {
        videoUrl = firstEpisode.videoUrl;
      }
    }

    return {
      _id: doc._id.toString(),
      id: doc._id.toString(),
      title: doc.title,
      description: doc.description || "",
      thumbnail: doc.thumbnail || doc.thumbnailUrl || "https://picsum.photos/300/450?random=1",
      videoUrl: videoUrl || "",
      genre: doc.category || doc.genre || "Drama",
      type: "series",
      isTrending: doc.isTrending || false,
      isNewRelease: doc.isNewRelease || false
    };
  } else {
    const series = doc.seriesId || {};
    return {
      _id: doc._id.toString(),
      id: doc._id.toString(),
      title: doc.title,
      description: series.description || doc.description || "",
      thumbnail: doc.thumbnailUrl || doc.thumbnail || series.thumbnail || "https://picsum.photos/300/450?random=2",
      videoUrl: doc.videoUrl || "",
      genre: series.category || doc.genre || "Drama",
      type: "video"
    };
  }
};

// 🔍 SEARCH VIDEOS (NOW SEARCHING ALL COLLECTIONS)
exports.searchVideos = async (req, res) => {
  try {
    const { query, userId, page = 1 } = req.query;
    const searchTerm = (query || "").trim();
    
    console.log("SEARCHING FOR:", searchTerm);

    if (!searchTerm) {
      return res.json({ success: false, message: "Search query is empty", results: [] });
    }

    const limit = 20;
    const skip = (page - 1) * limit;

    // 1. Search in Series
    const seriesResults = await Series.find({
      $or: [
        { title: { $regex: searchTerm, $options: "i" } },
        { category: { $regex: searchTerm, $options: "i" } }
      ]
    }).limit(limit);

    // 2. Search in Episodes
    const episodeResults = await Episode.find({
      title: { $regex: searchTerm, $options: "i" },
      $or: [{ isDiscover: false }, { isPremium: true }]
    }).populate("seriesId").limit(limit);

    // 3. Search in Content (The mismatch found!)
    const contentResults = await Content.find({
      $or: [
        { title: { $regex: searchTerm, $options: "i" } },
        { genre: { $regex: searchTerm, $options: "i" } }
      ]
    }).limit(limit);

    // Combine and remove duplicates
    const allResultsMap = new Map();
    
    await Promise.all(seriesResults.map(async s => allResultsMap.set(s._id.toString(), await formatVideo(s, 'series'))));
    await Promise.all(contentResults.map(async c => allResultsMap.set(c._id.toString(), await formatVideo(c, 'video'))));
    await Promise.all(episodeResults.map(async e => allResultsMap.set(e._id.toString(), await formatVideo(e, 'video'))));

    let finalResults = Array.from(allResultsMap.values()).slice(skip, skip + limit);

    if (userId && searchTerm) {
      SearchHistory.create({ userId, keyword: searchTerm }).catch(() => {});
    }

    console.log(`Found ${finalResults.length} total results for "${searchTerm}"`);

    if (finalResults.length === 0) {
      return res.status(200).json({ success: false, message: "Results not found", results: [] });
    }

    res.status(200).json({ success: true, results: finalResults });

  } catch (err) {
    console.error("SEARCH ERROR:", err);
    res.status(500).json({ success: false, error: err.message });
  }
};

exports.getPopularVideos = async (req, res) => {
  try {
    const episodes = await Episode.find({ isDiscover: true }).sort({ createdAt: -1 }).limit(10).populate("seriesId");
    const content = await Content.find({ type: 'discover' }).limit(5);
    
    const results = [
      ...await Promise.all(episodes.map(e => formatVideo(e, 'video'))),
      ...await Promise.all(content.map(c => formatVideo(c, 'video')))
    ];
    
    return res.status(200).json(results);
  } catch(err) {
    res.status(500).json({ error: err.message });
  }
};

// 📈 TRENDING SERIES (For Home Page)
exports.getTrendingSeries = async (req, res) => {
  try {
    const trendingSeries = await Series.find({ isTrending: true }).sort({ updatedAt: -1 }).limit(10);
    const results = await Promise.all(trendingSeries.map(s => formatVideo(s, 'series')));
    return res.status(200).json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 🎉 NEW RELEASES SERIES (For Home Page)
exports.getNewReleases = async (req, res) => {
  try {
    const newReleases = await Series.find({ isNewRelease: true }).sort({ updatedAt: -1 }).limit(10);
    const results = await Promise.all(newReleases.map(s => formatVideo(s, 'series')));
    return res.status(200).json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ... existing helper routes ...
exports.getGenres = async (req, res) => {
  try {
    const genres = await Genre.find().limit(10);
    if (genres.length > 0) return res.json(genres);
    res.json([{ name: "Drama" }, { name: "Comedy" }, { name: "Rom-Com" }, { name: "Thriller" }]);
  } catch (err) {
    res.json([{ name: "Drama" }, { name: "Comedy" }]);
  }
};

exports.getVideosByGenre = async (req, res) => {
  try {
    const { genreName } = req.params;
    const series = await Series.find({ category: { $regex: new RegExp(`^${genreName}$`, "i") } });
    const content = await Content.find({ genre: { $regex: new RegExp(`^${genreName}$`, "i") } });
    const seriesIds = series.map(s => s._id);
    const episodes = await Episode.find({ 
      seriesId: { $in: seriesIds },
      $or: [{ isDiscover: false }, { isPremium: true }]
    }).populate("seriesId");
    const results = [
      ...await Promise.all(series.map(s => formatVideo(s, 'series'))),
      ...await Promise.all(content.map(c => formatVideo(c, 'video'))),
      ...await Promise.all(episodes.map(e => formatVideo(e, 'video')))
    ];
    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getRecommendations = async (req, res) => {
  try {
    const episodes = await Episode.aggregate([
      { $match: { $or: [{ isDiscover: false }, { isPremium: true }] } },
      { $sample: { size: 3 } }
    ]);
    const populatedEpisodes = await Episode.populate(episodes, { path: "seriesId" });
    const content = await Content.aggregate([{ $sample: { size: 2 } }]);
    const results = [
      ...await Promise.all(populatedEpisodes.map(e => formatVideo(e, 'video'))), 
      ...await Promise.all(content.map(c => formatVideo(c, 'video')))
    ];
    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.searchSuggestions = async (req, res) => {
  try {
    const { query } = req.query;
    const searchTerm = (query || "").trim();
    if (!searchTerm) return res.json([]);
    const series = await Series.find({ title: { $regex: searchTerm, $options: "i" } }).limit(5);
    const content = await Content.find({ title: { $regex: searchTerm, $options: "i" } }).limit(5);
    const matches = [...new Set([...series, ...content].map(item => item.title))].slice(0, 5);
    res.json(matches);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};