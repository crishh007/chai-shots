const mongoose = require("mongoose");
const Series = require("./models/Series");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    console.log("--- UPDATING 'FRIENDSHIP' SERIES ---");
    const updated = await Series.findOneAndUpdate(
        { title: /friendship/i }, 
        { 
            isTrending: true,
            videoUrl: "https://res.cloudinary.com/dvptjzt00/video/upload/v1713364444/chai-ott/test_video_c2.mp4",
            thumbnail: "https://res.cloudinary.com/dvptjzt00/image/upload/v1713364444/chai-ott/test_thumb_c2.jpg"
        },
        { new: true }
    );
    
    if (updated) {
        console.log(`Success: Updated "${updated.title}" with videoUrl: ${updated.videoUrl}`);
    } else {
        console.log("Could not find 'friendship' series.");
    }
    
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
