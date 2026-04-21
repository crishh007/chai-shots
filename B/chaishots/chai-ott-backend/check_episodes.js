const mongoose = require("mongoose");
const Episode = require("./models/Episode");
const fs = require("fs");

mongoose.connect("mongodb+srv://sadanasri427_db_user:rjasAX2U6q9WSsYo@cluster0.ebpoo98.mongodb.net/?appName=Cluster0")
  .then(async () => {
    const episodes = await Episode.find().sort({ createdAt: -1 }).limit(5);
    fs.writeFileSync("output.json", JSON.stringify(episodes, null, 2));
    process.exit(0);
  })
  .catch((error) => {
    fs.writeFileSync("output.json", JSON.stringify({ error: error.message }));
    process.exit(1);
  });
