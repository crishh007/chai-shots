const mongoose = require("mongoose");
const Content = require("./models/Content");
const Episode = require("./models/Episode");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    // 1. Remove invalid embed URLs
    const deleted = await Content.deleteMany({ videoUrl: /embed/ });
    console.log(`Deleted ${deleted.deletedCount} invalid embed content items`);

    // 2. Mark some episodes as Discover so they show up
    const updated = await Episode.updateMany({}, { isDiscover: true });
    console.log(`Marked ${updated.modifiedCount} episodes as Discover`);
    
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
