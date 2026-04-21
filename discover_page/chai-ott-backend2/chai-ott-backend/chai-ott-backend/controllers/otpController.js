const Otp = require("../models/Otp");
const User = require("../models/User");
const jwt = require("jsonwebtoken");

// ✅ SEND OTP
exports.sendOtp = async (req, res) => {
  const isMongoConnected = req.app.get('isMongoConnected')();
  
  if (!isMongoConnected) {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    console.log("Mock OTP Send (No DB):", otp);
    return res.json({
      success: true,
      message: "OTP sent successfully (MOCK MODE)",
      otp: otp // Returning OTP for testing when DB is offline
    });
  }

  try {
    const { phone } = req.body;

    // 🔢 generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // 🗑️ delete old OTP if exists
    await Otp.deleteOne({ phone });

    // 💾 save new OTP
    await Otp.create({
      phone,
      otp,
      expiresAt: Date.now() + 5 * 60 * 1000 // 5 minutes
    });

    console.log("OTP for", phone, ":", otp);

    res.json({
      success: true,
      message: "OTP sent successfully",
      otp: otp // Returning OTP for development convenience
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error sending OTP",
      error: error.message
    });
  }
};

// ✅ VERIFY OTP + LOGIN USER
exports.verifyOtp = async (req, res) => {
  const isMongoConnected = req.app.get('isMongoConnected')();

  if (!isMongoConnected) {
    console.log("Mock OTP Verify (No DB) for:", req.body.phone);
    return res.json({
      success: true,
      message: "OTP verified successful (MOCK MODE)",
      token: "mock_jwt_token",
      user: { phone: req.body.phone }
    });
  }

  try {
    const { phone, otp } = req.body;

    // 🔍 find OTP record
    const record = await Otp.findOne({ phone });

    if (!record) {
      return res.status(400).json({ success: false, message: "OTP not found" });
    }

    if (record.otp !== otp) {
      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }

    if (record.expiresAt < Date.now()) {
      return res.status(400).json({ success: false, message: "OTP expired" });
    }

    // 🗑️ delete OTP after success
    await Otp.deleteOne({ phone });

    // 🔍 check if user exists
    let user = await User.findOne({ phone });

    // 🆕 create user if not exists
    if (!user) {
      user = new User({ phone });
      await user.save();
    }

    // 🔐 generate JWT token
    const token = jwt.sign(
      { userId: user._id },
      "secretkey",
      { expiresIn: "7d" }
    );

    res.json({
      success: true,
      message: "OTP verified & login successful",
      token,
      user
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error verifying OTP",
      error: error.message
    });
  }
};