const express = require("express");
const router = express.Router();

const watchHistoryController = require("../controllers/watchHistoryController");
const authMiddleware = require("../middleware/authMiddleware");

// ✅ Protected routes
router.post("/", authMiddleware, watchHistoryController.addHistory);
router.get("/", authMiddleware, watchHistoryController.getHistory);

module.exports = router;