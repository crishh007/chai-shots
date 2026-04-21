const mongoose = require("mongoose");

mongoose.connect("mongodb+srv://sadanasri427_db_user:rjasAX2U6q9WSsYo@cluster0.ebpoo98.mongodb.net/?appName=Cluster0")
  .then(() => {
    console.log("Database Name:", mongoose.connection.name);
    process.exit(0);
  })
  .catch((error) => {
    console.log("MongoDB Connection Error:", error);
    process.exit(1);
  });
