const Subscription = require("../models/Subscription");

// Create / Upgrade subscription
exports.subscribe = async (req, res) => {
  try {
    const { userId, plan } = req.body;

    const validDays = plan === "premium" ? 30 : 0;

    const validTill = new Date();
    validTill.setDate(validTill.getDate() + validDays);

    let subscription = await Subscription.findOne({ userId });

    if (subscription) {
      subscription.plan = plan;
      subscription.validTill = validTill;
      await subscription.save();
    } else {
      subscription = new Subscription({
        userId,
        plan,
        validTill
      });
      await subscription.save();
    }

    res.json({
      message: "Subscription updated",
      subscription
    });

  } catch (error) {
    res.status(500).json({
      message: "Subscription failed",
      error: error.message
    });
  }
};

// Check subscription
exports.checkSubscription = async (req, res) => {
  try {
    const { userId } = req.params;

    const subscription = await Subscription.findOne({ userId });

    res.json(subscription);

  } catch (error) {
    res.status(500).json({
      message: "Error checking subscription",
      error: error.message
    });
  }
};