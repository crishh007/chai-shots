const mongoose = require("mongoose");
const Episode = require("./models/Episode");
const Content = require("./models/Content");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    console.log("--- EPISODES ---");
    const episodes = await Episode.find();
    episodes.forEach(e => console.log(`Title: ${e.title}, isDiscover: ${e.isDiscover}, videoUrl: ${e.videoUrl}`));
    
    console.log("--- DISCOVER CONTENT ---");
    const content = await Content.find({ type: 'discover' });
    content.forEach(c => console.log(`Title: ${c.title}, videoUrl: ${c.videoUrl}`));
    
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
