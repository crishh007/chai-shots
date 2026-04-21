const express = require("express");
const router = express.Router();

const subscriptionController = require("../controllers/subscriptionController");

router.post("/", subscriptionController.subscribe);
router.get("/:userId", subscriptionController.checkSubscription);

module.exports = router;