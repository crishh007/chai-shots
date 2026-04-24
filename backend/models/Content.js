const mongoose = require("mongoose");

const contentSchema = new mongoose.Schema(
  {
    title:       { type: String, required: true },
    rating:      { type: String, default: "U" },        // U / A / UA
    genre:       { type: String, default: "" },
    type:        { type: String, default: "Trailer" },   // Trailer / Series / Movie
    description: { type: String, default: "" },
    videoUrl:    { type: String, required: true },       // asset path or CDN URL
    bgColor:     { type: String, default: "FF5B4A3F" },  // hex without #, with alpha
    isActive:    { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Content", contentSchema);