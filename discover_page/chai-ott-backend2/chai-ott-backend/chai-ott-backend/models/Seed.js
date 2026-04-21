// seed.js  — run once:  node seed.js
// Inserts 3 sample content documents so the Flutter app has data to display.

const mongoose = require("mongoose");
const Content  = require("./models/Content");

const MONGO_URI =
  "mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017," +
  "ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017," +
  "ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/" +
  "?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0";

const sampleContent = [
  {
    title:       "Love in Goa",
    rating:      "U",
    genre:       "Rom-Com",
    type:        "Trailer",
    description: "Small-town student travels to Goa chasing a hookup, clashes with a cynical influencer, and finds unexpected love along the way.",
    videoUrl:    "assets/videos/video1.mp4",   // Flutter asset path
    bgColor:     "FF5B4A3F",
  },
  {
    title:       "Dil Daaru Darbhanga",
    rating:      "A",
    genre:       "Drama",
    type:        "Trailer",
    description: "In dry Bihar, three friends are dragged into a deadly liquor racket. Fighting for love and survival in a lawless land.",
    videoUrl:    "assets/videos/video2.mp4",
    bgColor:     "FF8B3A2A",
  },
  {
    title:       "We Met on Twitter",
    rating:      "U",
    genre:       "Rom-Com",
    type:        "Trailer",
    description: "He follows her online and manages to win her over in real life. But when his intentions slip out, everything unravels.",
    videoUrl:    "assets/videos/video1.mp4",
    bgColor:     "FF2A4A6A",
  },
];

(async () => {
  await mongoose.connect(MONGO_URI);
  console.log("MongoDB connected");
  await Content.deleteMany({});   // clear old seed data
  await Content.insertMany(sampleContent);
  console.log("✅  Seeded", sampleContent.length, "content documents");
  await mongoose.disconnect();
})();