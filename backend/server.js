require("dotenv").config();
const express = require("express");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");

const app = express();

app.use(express.json());

connectDB();

const authMiddleware = require("./middleware/authMiddleware");

app.get("/", (req, res) => {
  res.send("Chai Shots API Running");
});

app.get("/api/profile", authMiddleware, (req, res) => {
  res.json({
    message: "This is a protected route",
    userId: req.user.id
  });
});

app.use("/api/auth", authRoutes);

app.listen(5000, () => {
  console.log("Server running on port 5000");
});