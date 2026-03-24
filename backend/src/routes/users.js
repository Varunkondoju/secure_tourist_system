const express = require("express");
const router = express.Router();
const { db } = require("../firebase");
const { encrypt, hashPII } = require("../security/crypto");

router.post("/register", async (req, res) => {
  try {
    const {
      preferredName,
      phone,
      email,
      aadhaar,
      emergencyContact
    } = req.body;

    // 🔴 Basic validation
    if (!preferredName || !phone || !email || !aadhaar || !emergencyContact) {
      return res.status(400).json({
        message: "Missing required registration fields"
      });
    }

    // 🔍 Check duplicate phone
    const phoneCheck = await db
      .collection("users")
      .where("phone", "==", phone)
      .get();

    if (!phoneCheck.empty) {
      return res.status(409).json({
        message: "Phone number already registered"
      });
    }

    // 🔍 Check duplicate email
    const emailCheck = await db
      .collection("users")
      .where("email", "==", email)
      .get();

    if (!emailCheck.empty) {
      return res.status(409).json({
        message: "Email already registered"
      });
    }

    // 🔍 Hash Aadhaar for uniqueness check
    const aadhaarHash = hashPII(aadhaar);

    const aadhaarCheck = await db
      .collection("users")
      .where("aadhaar_hash", "==", aadhaarHash)
      .get();

    if (!aadhaarCheck.empty) {
      return res.status(409).json({
        message: "Aadhaar already registered"
      });
    }

    // 🔐 Encrypt Aadhaar for secure storage
    const encryptedAadhaar = encrypt(aadhaar, process.env.PII_SECRET);

    // ✅ Create user
    const docRef = await db.collection("users").add({
      preferredName,
      phone,
      email,

      aadhaar_enc: encryptedAadhaar,
      aadhaar_hash: aadhaarHash,

      emergencyContact,

      createdAt: new Date(),
      lastActiveAt: new Date(),
      sosActive: false,
      emergencyActive: false
    });

    res.status(201).json({
      message: "User registered securely",
      userId: docRef.id
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Registration failed"
    });
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
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ message: "Phone is required" });
    }

    // Check user in Firebase
    const userRef = db.collection("users").where("phone", "==", phone);
    const snapshot = await userRef.get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "User not found" });
    }

    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();

    res.json({
      message: "Login successful",
      userId: userDoc.id,
      user: userData
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Login failed" });
  }
});
module.exports=router;