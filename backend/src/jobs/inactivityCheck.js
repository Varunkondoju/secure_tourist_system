const { db } = require("../firebase");

const THREE_HOURS_MS = 3 * 60 * 60 * 1000; // 3 HOURS 


async function checkInactivity() {
  const now = Date.now();
  const snapshot = await db.collection("users")
    .where("emergencyActive", "==", false)
    .get();

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const last = data.lastActiveAt?.toDate?.().getTime();

    if (!last) continue;

    if (now - last >= THREE_HOURS_MS) {
      await doc.ref.update({
        emergencyActive: true
      });
      console.log(`Auto-emergency triggered for user ${doc.id}`);
    }
  }
}

module.exports = { checkInactivity };
