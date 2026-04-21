const mongoose = require("mongoose");
const Content = require("./models/Content");
const Video = require("./models/Video");
const Series = require("./models/Series");
const Episode = require("./models/Episode");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    console.log("Content in DB:");
    console.log(await Content.find());
    console.log("Video in DB:");
    console.log(await Video.find());
    console.log("Series in DB:");
    console.log(await Series.find());
    console.log("Episode in DB:");
    console.log(await Episode.find());
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
