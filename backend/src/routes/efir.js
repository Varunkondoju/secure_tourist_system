const express = require("express");
const router = express.Router();
const { db } = require("../firebase");
const efirRoutes = require("./routes/efir");

// ✅ CREATE E-FIR
router.post("/create", async (req, res) => {
  try {
    const { userId, type, description, location } = req.body;

    if (!userId || !type || !description || !location) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    console.log("📄 FIR REQUEST:", req.body);

    // 🔥 GET USER DATA
    const userDoc = await db.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      return res.status(404).json({ message: "User not found" });
    }

    const userData = userDoc.data();

    const fullName = userData.fullName || "Unknown";
    const digitalId = userData.digitalId || "N/A";
    const phone = userData.phone || "N/A";

    console.log("👤 USER:", fullName, digitalId);

    // ✅ SAVE FIR (IMPORTANT: use SAME collection "firs")
    const firRef = await db.collection("firs").add({
      userId,
      fullName,
      digitalId,
      phone,
      type,
      description,
      location,
      status: "Pending",
      createdAt: new Date()
    });

    res.json({
      message: "E-FIR submitted successfully",
      firId: firRef.id
    });

  } catch (err) {
    console.error("❌ FIR ERROR:", err);
    res.status(500).json({ message: "E-FIR failed" });
  }
});


// ✅ GET ALL FIRs
router.get("/firs", async (req, res) => {
  try {
    const snapshot = await db.collection("firs").get();

    const firs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(firs);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch FIRs" });
  }
});

module.exports = router;