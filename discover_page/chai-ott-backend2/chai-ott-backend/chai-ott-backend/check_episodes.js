const mongoose = require("mongoose");
const Episode = require("./models/Episode");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    const eps = await Episode.find({ seriesId: "69e209492f091dd8a1b646d5" });
    console.log(`Found ${eps.length} episodes for test series.`);
    eps.forEach(e => console.log(`- ${e.title}: ${e.videoUrl}`));
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
