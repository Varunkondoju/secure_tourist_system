const express = require("express");
const router = express.Router();
const { db } = require("../firebase");
const { encrypt, hashPII } = require("../security/crypto");

const bcrypt = require("bcrypt");

router.post("/register", async (req, res) => {
  try {
    const {
      preferredName,
      fullName,
      phone,
      email,
      aadhaar,
      emergencyContact,
      emergencyContactRelation,
      password
    } = req.body;

    // Basic validation
    if (!email || !password || !fullName) {
      return res.status(400).json({
        message: "Full name, email and password are required"
      });
    }

    // Check existing user
    const existing = await db.collection("users")
      .where("email", "==", email)
      .get();

    if (!existing.empty) {
      return res.status(400).json({ message: "User already exists" });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Save user
    const userRef = await db.collection("users").add({
      preferredName,
      fullName,
      phone,
      email,
      aadhaar,
      emergencyContact,
      emergencyContactRelation,
      password: hashedPassword,
      createdAt: new Date(),
      lastActive: new Date(),
      emergencyActive: false
    });

    res.json({
      message: "User registered successfully",
      userId: userRef.id
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Register failed" });
  }
});

router.post("/activity", async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ message: "Missing userId" });
    }

    await db.collection("users").doc(userId).update({
      lastActiveAt: new Date(),
      emergencyActive: false
    });

    res.json({ message: "Activity updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to update activity" });
  }
});

module.exports = router;
// 🚨 User presses SOS
router.post("/sos", async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ message: "userId required" });
    }

    const userRef = db.collection("users").doc(userId);
    const snap = await userRef.get();

    if (!snap.exists) {
      return res.status(404).json({ message: "User not found" });
    }

    await userRef.update({
      sosActive: true,
      emergencyActive: true,
      lastActiveAt: new Date()
    });

    res.json({ message: "SOS activated. Emergency triggered." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "SOS failed" });
  }
});
// ❤️ Heartbeat to mark user active
router.post("/heartbeat", async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) {
      return res.status(400).json({ message: "userId required" });
    }

    await db.collection("users").doc(userId).update({
      lastActiveAt: new Date()
    });

    res.json({ message: "Activity updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Heartbeat failed" });
  }
});

const { decrypt } = require("../security/crypto");

router.get("/admin/:id", async (req, res) => {
  try {
    const userId = req.params.id;

    const doc = await db.collection("users").doc(userId).get();

    if (!doc.exists) {
      return res.status(404).json({ message: "User not found" });
    }

    const data = doc.data();

    // Decrypt Aadhaar
    const aadhaar = decrypt(
      data.aadhaar_enc,
      process.env.PII_SECRET
    );

    res.json({
      ...data,
      aadhaar
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch user" });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email & password required" });
    }

    const snapshot = await db.collection("users")
      .where("email", "==", email)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "User not found" });
    }

    const userDoc = snapshot.docs[0];
    const user = userDoc.data();

    // 🔥 IMPORTANT
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: "Invalid password" });
    }

    res.json({
      message: "Login successful",
      userId: userDoc.id,
      user : userDoc.data()
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Login failed" });
  }
});
router.put("/update/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const updates = req.body;

    await db.collection("users").doc(userId).update(updates);

    res.json({ message: "Profile updated successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Update failed" });
  }
});
module.exports=router;