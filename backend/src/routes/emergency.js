const express = require("express");
const router = express.Router();
const { db } = require("../firebase");
const { logToBlockchain } = require("../blockchain/logger");
const { hashPII } = require("../security/crypto");

router.post("/sos", async (req, res) => {
  try {
    const { userId, location } = req.body;

    if (!userId || !location) {
      return res.status(400).json({ message: "Missing fields" });
    }

    console.log("SOS HIT:", userId, location);

    // ✅ Save SOS separately (MAIN FEATURE)
    const sosRef = await db.collection("sos").add({
      userId,
      location,
      status: "ACTIVE",
      createdAt: new Date()
    });

    // ⚠️ OPTIONAL: update user (ONLY if valid ID)
    try {
      await db.collection("users").doc(userId).update({
        emergencyActive: true,
        lastLocation: location,
        lastActiveAt: new Date()
      });
    } catch (e) {
      console.log("User update skipped (invalid userId)");
    }

    // ✅ Blockchain log
    await logToBlockchain(
     "EMERGENCY_TRIGGERED",
     digitalId, // 🔥 USE DIGITAL ID
     "user"
    );

    res.json({
      message: "SOS triggered successfully",
      sosId: sosRef.id
    });

  } catch (err) {
    console.error("SOS ERROR:", err);
    res.status(500).json({
      message: "SOS failed",
      error: err.message
    });
  }
});

module.exports = router;