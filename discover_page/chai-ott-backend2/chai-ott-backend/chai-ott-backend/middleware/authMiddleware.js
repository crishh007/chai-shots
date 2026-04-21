const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  try {
    let token = req.headers.authorization;

    console.log("👉 HEADER RECEIVED:", token);

    if (!token) {
      return res.status(401).json({ message: "No token provided" });
    }

    // Remove Bearer
    if (token.startsWith("Bearer ")) {
      token = token.split(" ")[1];
    }

    console.log("👉 TOKEN AFTER SPLIT:", token);

    const decoded = jwt.verify(token, "secretkey");

    console.log("👉 DECODED:", decoded);

    req.userId = decoded.userId;

    next();
  } catch (error) {
    console.log("❌ JWT ERROR:", error.message);
    return res.status(401).json({ message: "Invalid token" });
  }
};