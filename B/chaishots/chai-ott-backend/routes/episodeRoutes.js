const express = require("express");
const router = express.Router();

const episodeController = require("../controllers/episodeController");
const upload = require("../middleware/upload");

router.post("/upload", upload.single("video"), episodeController.uploadEpisode);
router.post("/create", episodeController.createEpisode);
router.get("/", episodeController.getEpisodes);
router.get("/series/:seriesId", episodeController.getEpisodesBySeries);
router.delete("/:id", episodeController.deleteEpisode);

module.exports = router;