const mongoose = require("mongoose");
const Series = require("./models/Series");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    console.log("--- SEARCHING FOR DUPLICATE SERIES ---");
    const all = await Series.find({ title: /friendship/i });
    console.log(`Found ${all.length} matches.`);
    all.forEach(s => {
        console.log(`- Title: ${s.title}, ID: ${s._id}, Trending: ${s.isTrending}, Video: ${s.videoUrl ? 'YES' : 'NO'}`);
    });
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
