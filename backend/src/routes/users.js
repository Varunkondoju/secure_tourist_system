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
      fullName,
      phone,
      email,
      aadhaar,
      emergencyContact,
      relation,
      password
    } = req.body;

    if (!email || !password || !aadhaar || !fullName) {
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

    // ✅ CLEAN DATA (NO undefined)
    const userData = {
      fullName,
      phone: phone || "",
      email,
      aadhaar,
      emergencyContact: emergencyContact || "",
      relation: relation || "",
      password: hashedPassword,
      digitalId,
      createdAt: new Date()
    };

    // 🔥 REMOVE undefined fields (VERY IMPORTANT)
    Object.keys(userData).forEach(
      key => userData[key] === undefined && delete userData[key]
    );

    // 💾 save user
    const userRef = await db.collection("users").add(userData);

    res.json({
      message: "User registered",
      userId: userRef.id,
      digitalId
    });

  } catch (err) {
    console.error("REGISTER ERROR:", err);
    res.status(500).json({
      message: "Register failed",
      error: err.message
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
const nodemailer = require("nodemailer");

router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;

    const snapshot = await db.collection("users")
      .where("email", "==", email)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "User not found" });
    }

    const userDoc = snapshot.docs[0];

    // Create reset token (simple)
    const resetToken = userDoc.id;

    const resetLink = `https://your-app/reset-password/${resetToken}`;

    // Send email
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: "Reset Password",
      text: `Click to reset: ${resetLink}`
    });

    res.json({ message: "Reset link sent to email" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to send reset link" });
  }
});

router.post("/reset-password", async (req, res) => {
  try {
    const { userId, newPassword } = req.body;

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await db.collection("users").doc(userId).update({
      password: hashedPassword
    });

    res.json({ message: "Password updated successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Reset failed" });
  }
});