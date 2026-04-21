const mongoose = require("mongoose");
const Episode = require("./models/Episode");
const Series = require("./models/Series");
const fs = require("fs");

mongoose.connect("mongodb+srv://sadanasri427_db_user:rjasAX2U6q9WSsYo@cluster0.ebpoo98.mongodb.net/?appName=Cluster0")
  .then(async () => {
    const series = await Series.find();
    const episodes = await Episode.find();
    
    const output = {
      series: series.map(s => ({ id: s._id, title: s.title })),
      episodes: episodes.map(e => ({ id: e._id, title: e.title, seriesId: e.seriesId }))
    };
    
    fs.writeFileSync("relations_check.json", JSON.stringify(output, null, 2));
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
