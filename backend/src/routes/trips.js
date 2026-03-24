const express = require("express");
const router = express.Router();
const { db } = require("../firebase");

// ➕ ADD NEW TRIP
router.post("/add", async (req, res) => {
  try {
    const { userId, destination, date } = req.body;

    if (!userId || !destination || !date) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const tripRef = await db.collection("trips").add({
      userId,
      destination,
      date,
      status: "Upcoming",
      createdAt: new Date()
    });

    res.json({
      message: "Trip added successfully",
      tripId: tripRef.id
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Trip creation failed" });
  }
});


// 📥 GET USER TRIPS
router.get("/user/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    const snapshot = await db.collection("trips")
      .where("userId", "==", userId)
      .get();

    const trips = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(trips);

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch trips" });
  }
});

module.exports = router;