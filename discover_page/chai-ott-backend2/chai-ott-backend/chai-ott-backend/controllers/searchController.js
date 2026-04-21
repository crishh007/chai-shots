const localVideos = require("../data/local_data");
const SearchHistory = require("../models/SearchHistory");
const Genre = require("../models/Genre");

// 🔍 SEARCH VIDEOS (NOW LOCAL JSON)
exports.searchVideos = async (req, res) => {
  try {
    const { query, userId, page = 1 } = req.query;
    const searchTerm = (query || "").toLowerCase();

    console.log("SEARCH QUERY:", searchTerm);

    // Filter local data (Refined logic: Title inclusion + Strict Genre)
    const filteredVideos = localVideos.filter(v => {
      const titleMatch = v.title.toLowerCase().includes(searchTerm);
      const genreMatch = (v.genre && v.genre.toLowerCase() === searchTerm);
      return titleMatch || genreMatch;
    });

    // Pagination (Local)
    const limit = 10;
    const startIndex = (page - 1) * limit;
    const paginatedVideos = filteredVideos.slice(startIndex, startIndex + limit);

    // ✅ Background history storage (attempt but don't block)
    if (userId && query) {
      SearchHistory.create({ userId, keyword: query }).catch(() => {});
    }

    console.log(`Found ${filteredVideos.length} results for "${searchTerm}"`);
    if (filteredVideos.length > 0) {
      console.log("First result title:", filteredVideos[0].title);
    }

    res.json({
      results: paginatedVideos
    });

  } catch (err) {
    console.error("SEARCH ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};


// 🔥 POPULAR VIDEOS (NOW FROM LOCAL DATA)
exports.getPopularVideos = async (req, res) => {
  // Return first few items or specific "Discover" items
  const discoverVideos = localVideos.filter(v => v.type === "Discover" || v.id.startsWith("discover"));
  
  if (discoverVideos.length > 0) {
    return res.status(200).json(discoverVideos);
  }
  
  // Fallback to first 3
  return res.status(200).json(localVideos.slice(0, 3));
};



// 🎭 GET ALL GENRES (Simplified local fallback)
exports.getGenres = async (req, res) => {
  try {
    const genres = await Genre.find().limit(10);
    if (genres.length > 0) return res.json(genres);
    
    // Fallback static genres
    res.json([
      { name: "Drama" }, { name: "Comedy" }, { name: "Rom-Com" }, { name: "Thriller" }
    ]);
  } catch (err) {
    res.json([{ name: "Drama" }, { name: "Comedy" }]);
  }
};


// 🎬 GET VIDEOS BY GENRE
exports.getVideosByGenre = async (req, res) => {
  try {
    const { genreName } = req.params;
    const matches = localVideos.filter(v => v.genre && v.genre.toLowerCase() === genreName.toLowerCase());
    res.json(matches);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// 🤖 RECOMMENDATIONS
exports.getRecommendations = async (req, res) => {
  try {
    // Return random selection from local data for recommendations
    const shuffled = [...localVideos].sort(() => 0.5 - Math.random());
    res.json(shuffled.slice(0, 5));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ✨ SEARCH SUGGESTIONS
exports.searchSuggestions = async (req, res) => {
  try {
    const { query } = req.query;
    const searchTerm = (query || "").toLowerCase();
    
    const matches = localVideos
      .filter(v => v.title.toLowerCase().includes(searchTerm))
      .map(v => v.title)
      .slice(0, 5);

    res.json(matches);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};