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
const express = require("express");
const router = express.Router();
const { db } = require("../firebase");


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

const express = require("express");
const router = express.Router();
const { db } = require("../firebase");


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