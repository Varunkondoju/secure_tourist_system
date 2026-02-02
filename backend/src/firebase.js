const admin = require("firebase-admin");

// Load service account key
const serviceAccount = require("../firebase-key.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Firestore reference
const db = admin.firestore();

module.exports = { db };
