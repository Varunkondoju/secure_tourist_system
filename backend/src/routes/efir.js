const express = require("express");
const router = express.Router();
const { db } = require("../firebase");

// CREATE E-FIR
router.post("/create", async (req, res) => {
  try {
    const { userId, type, description, location } = req.body;

    if (!userId || !type || !description) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const firRef = await db.collection("efir").add({
      userId,
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
    console.error(err);
    res.status(500).json({ message: "E-FIR failed" });//if not filled
  }
});

module.exports = router;