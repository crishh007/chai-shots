const mongoose = require("mongoose");
const Episode = require("./models/Episode");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    console.log("--- SEARCHING FOR MATCHING EPISODES ---");
    const all = await Episode.find({ title: /friendship/i });
    console.log(`Found ${all.length} matches.`);
    all.forEach(e => {
        console.log(`- Title: ${e.title}, ID: ${e._id}, Video: ${e.videoUrl}`);
    });
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
