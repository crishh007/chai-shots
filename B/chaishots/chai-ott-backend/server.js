const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const authRoutes = require("./routes/authRoutes");
const seriesRoutes = require("./routes/seriesRoutes");
const episodeRoutes = require("./routes/episodeRoutes");
const watchHistoryRoutes = require("./routes/watchHistoryRoutes");
const subscriptionRoutes = require("./routes/subscriptionRoutes");
const app = express();

app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect("mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0")
.then(() => {
    console.log("MongoDB Connected Successfully");
})
.catch((error) => {
    console.log("MongoDB Connection Error:", error);
});

// routes
app.use("/api/auth", authRoutes);
app.use("/api/series", seriesRoutes);
app.use("/api/episodes", episodeRoutes);
app.use("/api/history", watchHistoryRoutes);
app.use("/api/subscription", subscriptionRoutes);
// test route
app.get("/", (req, res) => {
    res.send("Chai OTT Backend Running");
});

// server start (ONLY ONE TIME)
const PORT = process.env.PORT || 5001;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});