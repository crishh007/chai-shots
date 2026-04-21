const mongoose = require("mongoose");
const Series = require("./models/Series");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    const series = await Series.find();
    console.log("--- ALL SERIES ---");
    series.forEach(s => console.log(`ID: ${s._id}, Title: ${s.title}, isTrending: ${s.isTrending}`));
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
