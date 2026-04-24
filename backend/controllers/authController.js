const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// ✅ Register User
exports.register = async (req, res) => {
  const isMongoConnected = req.app.get('isMongoConnected')();
  
  if (!isMongoConnected) {
    console.log("Mock Register triggered (No DB)");
    return res.json({
      message: "User registered successfully (MOCK MODE)",
      note: "Data not persisted because MongoDB is offline"
    });
  }

  try {
    const { name, email, password } = req.body;
// ... rest of the original code ...

    // check user exists
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: "User already exists" });
    }

    // hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // create user
    user = new User({
      name,
      email,
      password: hashedPassword
    });

    await user.save();

    res.json({
      message: "User registered successfully"
    });

  } catch (error) {
    res.status(500).json({
      message: "Register failed",
      error: error.message
    });
  }
};



// ✅ Login User
exports.login = async (req, res) => {
  const isMongoConnected = req.app.get('isMongoConnected')();

  if (!isMongoConnected) {
    console.log("Mock Login triggered (No DB)");
    return res.json({
      message: "Login successful (MOCK MODE)",
      token: "mock-jwt-token",
      user: {
        _id: "mock_user_id",
        name: "Mock User",
        email: req.body.email || "mock@example.com"
      }
    });
  }

  try {
    const { email, password } = req.body;
// ... rest of the original code ...

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign(
      { userId: user._id },
      "secretkey",
      { expiresIn: "7d" }
    );

    res.json({
      message: "Login successful",
      token,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email
      }
    });

  } catch (error) {
    res.status(500).json({
      message: "Login failed",
      error: error.message
    });
  }
};