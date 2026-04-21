const mongoose = require("mongoose");
const Content = require("./models/Content");

mongoose.connect('mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0')
.then(async () => {
    const data = [
        {
            title: "Veena",
            description: "A beautiful series",
            thumbnailUrl: "https://res.cloudinary.com/dp6dikfcb/image/upload/v1774961530/veena_emuxir.jpg",
            genre: "Drama",
            type: "series",
            videoUrl: "assets/videos/video1.mp4"
        },
        {
            title: "Panimanishiki Padipoya",
            description: "Popular series",
            thumbnailUrl: "https://res.cloudinary.com/dp6dikfcb/image/upload/v1775062479/pani_nslbzp.jpg",
            genre: "Romance",
            type: "series",
            videoUrl: "assets/videos/video2.mp4"
        }
    ];

    for (const item of data) {
        await Content.findOneAndUpdate({ title: item.title }, item, { upsert: true });
    }
    
    console.log("✅ Seeded Veena and Panimanishiki into Content collection");
    process.exit(0);
})
.catch(err => {
    console.error(err);
    process.exit(1);
});
