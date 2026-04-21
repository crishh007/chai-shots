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
mongoose.connect('mongodb://127.0.0.1:27017/chaishots', {
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

// Setup History Endpoints
app.get('/api/history', require('./controllers/watchHistoryController').getHistory);
app.post('/api/history', require('./controllers/watchHistoryController').addHistory);

// Setup Claps Endpoints (Mocked)
app.get('/api/claps/:id', (req, res) => res.json([]));
app.post('/api/claps', (req, res) => res.json({ message: "Clap received" }));

// Setup Episodes and Series Endpoints (Using local data)
const localVideos = require('./data/local_data');
app.get('/api/episodes', (req, res) => res.json(localVideos.filter(v => v.type === 'video' || v.type === 'episode')));
app.get('/api/episodes/:id', (req, res) => {
  const video = localVideos.find(v => v.id === req.params.id);
  res.json(video || {});
});
app.get('/api/series', (req, res) => res.json(localVideos.filter(v => v.type === 'series')));

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
