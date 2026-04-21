const cloudinary = require('./config/cloudinary');

async function testCloudinary() {
  try {
    console.log("Testing Cloudinary connection...");
    const result = await cloudinary.api.ping();
    console.log("✅ Successfully connected to Cloudinary!");
    console.log("Ping response:", result);
  } catch (error) {
    console.error("❌ Failed to connect to Cloudinary.");
    console.error("Error details:", error.message || error);
  }
}

testCloudinary();
