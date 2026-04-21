const express = require("express");
const router = express.Router();

const seriesController = require("../controllers/seriesController");
const upload = require("../middleware/upload");

router.post("/create", upload.fields([{ name: "thumbnail", maxCount: 1 }, { name: "video", maxCount: 1 }]), seriesController.createSeries);
router.get("/", seriesController.getSeries);
router.delete("/:id", seriesController.deleteSeries);

module.exports = router;