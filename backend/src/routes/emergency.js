const express = require("express");
const router = express.Router();
const { db } = require("../firebase");
const { logToBlockchain } = require("../blockchain/logger");

router.post("/sos", async (req, res) => {
  try {
    const { userId, location } = req.body;

    // ✅ Validate input
    if (!userId || !location) {
      return res.status(400).json({ message: "Missing fields" });
    }

    console.log("🚨 SOS HIT:", userId, location);

    // ✅ Get user from Firestore
    const userDoc = await db.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      return res.status(404).json({ message: "User not found" });
    }

    const userData = userDoc.data();

    const digitalId = userData.digitalId;
    const preferredName = userData.preferredName;

    console.log("USER DATA:", userData);
    console.log("DIGITAL ID:", digitalId);

    // ❌ Safety check
    if (!digitalId) {
      return res.status(400).json({
        message: "digitalId missing for this user"
      });
    }

    // ✅ Save SOS in Firestore
    const sosRef = await db.collection("sos").add({
      userId,
      digitalId, // 🔥 store it
      preferredName,
      location,
      status: "ACTIVE",
      createdAt: new Date()
    });

    // ✅ Update user status
    await db.collection("users").doc(userId).update({
      emergencyActive: true,
      lastLocation: location,
      lastActiveAt: new Date()
    });

    // ✅ Send to blockchain (safe try-catch)
    try {
      await logToBlockchain(
        "EMERGENCY_TRIGGERED",
        digitalId,
        "MOBILE_APP"
      );
      console.log("✅ Blockchain logged");
    } catch (blockErr) {
      console.error("⚠️ Blockchain error:", blockErr.message);
    }

    // ✅ Final response
    res.json({
      message: "SOS triggered successfully",
      sosId: sosRef.id
    });

  } catch (err) {
    console.error("❌ SOS ERROR:", err);
    res.status(500).json({
      message: "SOS failed",
      error: err.message
    });
  }
});

module.exports = router;