const mongoose = require("mongoose");

const clapSchema = new mongoose.Schema(
  {
    contentId:  { type: mongoose.Schema.Types.ObjectId, ref: "Content" },
    personName: { type: String },
    role:       { type: String },
    count:      { type: Number, default: 1 },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Clap", clapSchema);