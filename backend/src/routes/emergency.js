const express = require("express");
const router = express.Router();
const { db } = require("../firebase");
const { logToBlockchain } = require("../blockchain/logger");
const { hashPII } = require("../security/crypto");

router.post("/sos", async (req, res) => {
  try {
    const { userId, location } = req.body;

    if (!userId) {
      return res.status(400).json({ message: "Missing userId" });
    }

    // Update Firebase
    await db.collection("users").doc(userId).update({
      emergencyActive: true,
      lastLocation: location || null,
      lastActiveAt: new Date()
    });

    // Log to blockchain
    await logToBlockchain(
      "EMERGENCY_TRIGGERED",
      hashPII(userId),
      "user"
    );

    res.json({ message: "SOS triggered successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "SOS failed" });
  }
});

module.exports = router;