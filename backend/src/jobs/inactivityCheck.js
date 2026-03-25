const { db } = require("../firebase");

const THREE_MINUTES_MS = 3 * 60 * 1000; // ✅ 3 minutes

async function checkInactivity() {
  const now = Date.now();

  const snapshot = await db.collection("users")
    .where("emergencyActive", "==", false)
    .get();

  for (const doc of snapshot.docs) {
    const data = doc.data();

    const last = data.lastActiveAt?.toDate?.().getTime();

    if (!last) continue;

    // ⏱️ 3 minutes check
    if (now - last >= THREE_MINUTES_MS) {

      console.log("🚨 AUTO SOS for user:", doc.id);

      // ✅ 1. UPDATE USER
      await doc.ref.update({
        emergencyActive: true
      });

      // ✅ 2. CREATE SOS (VERY IMPORTANT)
      await db.collection("sos").add({
        userId: doc.id,
        location: data.lastLocation || "unknown",
        status: "AUTO_TRIGGERED",
        createdAt: new Date()
      });
    }
  }
}

module.exports = { checkInactivity };
