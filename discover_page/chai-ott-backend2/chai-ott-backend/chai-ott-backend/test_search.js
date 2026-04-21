const mongoose = require("mongoose");
const Episode = require("./models/Episode");
const Series = require("./models/Series");

const formatVideo = (doc, type) => {
    if (type === 'series') {
      return {
        id: doc._id.toString(),
        title: doc.title,
        description: doc.description || "",
        thumbnailUrl: doc.thumbnail || "https://picsum.photos/300/450?random=1",
        videoUrl: "", // Series might not have a direct video URL unless it's a trailer
        genre: doc.category || "Drama",
        type: "series"
      };
    } else {
      // For episodes, we might need to populate seriesId to get genre/thumbnail
      const series = doc.seriesId || {};
      return {
        id: doc._id.toString(),
        title: doc.title,
        description: series.description || doc.description || "",
        thumbnailUrl: series.thumbnail || doc.thumbnailUrl || "https://picsum.photos/300/450?random=2",
        videoUrl: doc.videoUrl || "assets/videos/video1.mp4",
        genre: series.category || doc.genre || "Drama",
        type: "video"
      };
    }
  };

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    const searchTerm = process.argv[2] || "test";
    
    const limit = 10;
    const skip = 0;

    // Search in Series
    const seriesResults = await Series.find({
      $or: [
        { title: { $regex: searchTerm, $options: "i" } },
        { category: { $regex: searchTerm, $options: "i" } }
      ]
    }).limit(limit);

    // Search in Episodes
    const episodeResults = await Episode.find({
      title: { $regex: searchTerm, $options: "i" }
    }).populate("seriesId").limit(limit);

    let results = [
      ...seriesResults.map(s => formatVideo(s, 'series')),
      ...episodeResults.map(e => formatVideo(e, 'video'))
    ];

    results = results.slice(skip, skip + limit);

    console.log(`Found ${results.length} results for "${searchTerm}"`);
    console.log(JSON.stringify(results, null, 2));
    
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
