const mongoose = require("mongoose");
const Series = require("./models/Series");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    console.log("--- CLEANING UP TEST DATA ---");
    // Remove the trending flag from my poisoned entry
    await Series.findOneAndUpdate(
        { title: "friendship" }, 
        { isTrending: false }
    );
    
    // Find a series that might have real data (if any)
    const all = await Series.find();
    console.log("Current Series in DB:");
    all.forEach(s => console.log(`- ${s.title} (Trending: ${s.isTrending}, Thumbnail: ${s.thumbnail ? 'YES' : 'NO'})`));
    
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
