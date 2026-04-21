const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const app = express();
const port = 5000;

app.use(cors());
app.use(express.json());

// MongoDB Connection Status Flag
let isMongoConnected = false;

// Connect to MongoDB with connection options to prevent buffering timeouts
mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0', {
  serverSelectionTimeoutMS: 5000, // Timeout after 5s if MongoDB is not running
  family: 4 // Force IPv4 to avoid localhost resolution issues
})
  .then(() => {
    isMongoConnected = true;
    console.log('✅ MongoDB connected...');
  })
  .catch(err => {
    isMongoConnected = false;
    console.error('❌ MongoDB connection error:', err.message);
    console.log('💡 TIP: Ensure MongoDB is running locally on port 27017');
    console.log('⚠️  Backend will continue running in MOCK mode for DB-dependent routes.');
  });

// Export connection status for controllers to use
app.set('isMongoConnected', () => isMongoConnected);

// Load controllers
const authController = require('./controllers/authController');
const episodeController = require('./controllers/episodeController');
const searchController = require('./controllers/searchController');
const seriesController = require('./controllers/seriesController');
const upload = require('./middleware/upload');

// Test route
app.get('/api', (req, res) => {
  res.json({ message: 'Chai Shots API is running' });
});

// Setup some basic routes
app.post('/api/auth/register', authController.register);
app.post('/api/auth/login', authController.login);

// Added Mock Routes to prevent Flutter 404 exceptions
// Setup Content/Discover Endpoint
// Setup Content/Discover Endpoint
app.get('/api/discover', searchController.getPopularVideos); // Discover uses this feed

// Setup Search Endpoint
app.get('/api/search', searchController.searchVideos);

// Setup Trending Endpoint
app.get('/api/trending', searchController.getTrendingSeries);

// Setup New Releases Endpoint
app.get('/api/new-releases', searchController.getNewReleases);

// Setup History Endpoints
app.get('/api/history', require('./controllers/watchHistoryController').getHistory);
app.post('/api/history', require('./controllers/watchHistoryController').addHistory);

// Setup Claps Endpoints (Mocked)
app.get('/api/claps/:id', (req, res) => res.json([]));
app.post('/api/claps', (req, res) => res.json({ message: "Clap received" }));

// Setup Episodes and Series Endpoints (Using DB)
const Episode = require('./models/Episode');
const Series = require('./models/Series');

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
      thumbnail: doc.thumbnail || "https://picsum.photos/300/450?random=1",
      videoUrl: videoUrl || "",
      genre: doc.category || "Drama",
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

app.get('/api/episodes', async (req, res) => {
  try {
    const episodes = await Episode.find().populate("seriesId");
    const formatted = await Promise.all(episodes.map(e => formatVideo(e, 'video')));
    res.json(formatted);
  } catch(err) {
    res.status(500).json({error: err.message});
  }
});
app.get('/api/episodes/:id', async (req, res) => {
  try {
    const episode = await Episode.findById(req.params.id).populate("seriesId");
    if(episode) res.json(await formatVideo(episode, 'video'));
    else res.json({});
  } catch(err) {
    res.status(500).json({error: err.message});
  }
});
app.get('/api/series', async (req, res) => {
  try {
    const series = await Series.find();
    const formatted = await Promise.all(series.map(s => formatVideo(s, 'series')));
    res.json(formatted);
  } catch(err) {
    res.status(500).json({error: err.message});
  }
});

// Setup Episode Upload, Fetch and Delete Endpoints
app.post('/api/episodes/upload', upload.single('video'), episodeController.uploadEpisode);
app.get('/api/episodes/series/:seriesId', episodeController.getEpisodesBySeries);
app.delete('/api/episodes/:id', episodeController.deleteEpisode);

// Setup Series Create and Delete Endpoints
app.post('/api/series/create', upload.fields([
  { name: 'thumbnail', maxCount: 1 },
  { name: 'video', maxCount: 1 }
]), seriesController.createSeries);

app.delete('/api/series/:id', seriesController.deleteSeries);

let savedVideos = [];

app.get('/api/saved', (req, res) => {
  res.json({ saved: savedVideos });
});

app.post('/api/saved', (req, res) => {
  console.log("======= BACKEND SAVE REQUEST =======");
  console.log("URL: POST /api/saved");
  console.log("Body:", req.body);
  console.log("====================================");
  const { contentId, videoId, title, videoUrl, thumbnailUrl } = req.body;
  const idToSave = contentId || videoId;
  if (!idToSave) return res.status(400).json({ message: "ID is required" });
  
  const index = savedVideos.findIndex(v => (v.contentId || v.videoId || v._id) === idToSave);
  if (index === -1) {
    savedVideos.push(req.body);
  }
  res.json({ message: "Saved Successfully", saved: savedVideos });
});

app.delete('/api/saved/:id', (req, res) => {
  savedVideos = savedVideos.filter(v => (v.contentId || v.videoId) !== req.params.id);
  res.json({ message: "Removed successfully" });
});


// Setup OTP Endpoints
const otpController = require('./controllers/otpController');
app.post('/api/otp/send-otp', otpController.sendOtp);
app.post('/api/otp/verify-otp', otpController.verifyOtp);

// Start server
app.listen(port, () => {
  console.log(`=========================================`);
  console.log(`Backend Server is running on port: ${port}`);
  console.log(`=========================================`);
});
