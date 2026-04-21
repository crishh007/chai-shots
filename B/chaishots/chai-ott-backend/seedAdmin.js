const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const User = require("./models/User");

mongoose.connect("mongodb://manju:Manju123@ac-kshxhnq-shard-00-00.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-01.xdzqu71.mongodb.net:27017,ac-kshxhnq-shard-00-02.xdzqu71.mongodb.net:27017/?ssl=true&replicaSet=atlas-ycdi94-shard-0&authSource=admin&appName=Cluster0")
.then(async () => {
    console.log("MongoDB Connected for Seeding");
    
    const email = "adimchai@gmail.com";
    const password = "admin@123";
    
    let user = await User.findOne({ email });
    if (user) {
        console.log("User already exists. Updating password...");
        user.password = await bcrypt.hash(password, 10);
        await user.save();
        console.log("User password updated successfully.");
    } else {
        console.log("Creating new admin user...");
        const hashedPassword = await bcrypt.hash(password, 10);
        user = new User({
            name: "Admin",
            email: email,
            password: hashedPassword
        });
        await user.save();
        console.log("Admin user created successfully.");
    }
    process.exit(0);
})
.catch((err) => {
    console.error("Error seeding admin user:", err);
    process.exit(1);
});
