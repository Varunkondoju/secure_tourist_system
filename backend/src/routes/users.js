const express = require("express");
const router = express.Router();
const { db } = require("../firebase");
const { encrypt, hashPII } = require("../security/crypto");

const bcrypt = require("bcrypt");

// 🔥 add this function ABOVE register
function generateDigitalId(aadhaar) {
  const last4 = aadhaar.slice(-4);
  const random = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `IND-${last4}-${random}`;
}

router.post("/register", async (req, res) => {
  try {
    const {
      preferredName,
      phone,
      email,
      aadhaar,
      emergencyContact,
      relation,
      password
    } = req.body;

    if (!email || !password || !aadhaar) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // 🔍 check existing user
    const existing = await db.collection("users")
      .where("email", "==", email)
      .get();

    if (!existing.empty) {
      return res.status(400).json({ message: "User already exists" });
    }

    // 🔐 hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 🆔 generate digital ID
    const digitalId = generateDigitalId(aadhaar);

    // 💾 save user
    const userRef = await db.collection("users").add({
      preferredName,
      phone,
      email,
      aadhaar,
      emergencyContact,
      relation,
      password: hashedPassword,
      digitalId, // 🔥 IMPORTANT
      createdAt: new Date()
    });

    res.json({
      message: "User registered",
      userId: userRef.id,
      digitalId // 🔥 send back
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

    console.log("UPDATE REQUEST:", userId, updates); // debug

    const userRef = db.collection("users").doc(userId);

    const doc = await userRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "User not found" });
    }

    await userRef.update(updates);

    res.json({ message: "Profile updated successfully" });

  } catch (err) {
    console.error("UPDATE ERROR:", err);
    res.status(500).json({
      message: "Update failed",
      error: err.message
    });
  }
});
module.exports=router;
function generateDigitalId(aadhaar) {
  const last4 = aadhaar.slice(-4);
  const random = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `IND-${last4}-${random}`;
}