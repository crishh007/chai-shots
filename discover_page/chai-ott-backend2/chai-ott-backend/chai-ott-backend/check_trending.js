const mongoose = require("mongoose");
const Series = require("./models/Series");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    console.log("--- SCANNING FOR TRENDING CONTENT ---");
    const trending = await Series.find({ isTrending: true });
    console.log(`Found ${trending.length} trending series.`);
    trending.forEach(s => {
        console.log(`- Title: ${s.title}, ID: ${s._id}`);
    });
    
    if (trending.length === 0) {
        console.log("No trending series found. Setting 'test series' to trending as a fallback...");
        await Series.findOneAndUpdate({ title: /test series/i }, { isTrending: true });
        console.log("Updated 'test series' to trending.");
    }
    
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
