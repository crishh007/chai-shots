const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  name: {
    type: String
  },
  email: {
    type: String,
    unique: true,
    sparse: true   // ✅ important (allows null values)
  },
  password: {
    type: String
  },
  phone: {
    type: String,
    unique: true
  }
}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);