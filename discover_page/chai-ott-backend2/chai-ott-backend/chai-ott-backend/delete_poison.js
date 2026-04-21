const mongoose = require("mongoose");
const Series = require("./models/Series");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    console.log("--- DELETING POISONED DATA ---");
    const result = await Series.deleteOne({ title: "friendship" });
    console.log(`Deleted: ${result.deletedCount} document(s)`);
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
