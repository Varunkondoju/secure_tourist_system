require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { db } = require("./firebase");
const userRoutes = require("./routes/users");
const emergencyRoutes = require("./routes/emergency");
const { checkInactivity } = require("./jobs/inactivityCheck");
const { logToBlockchain } = require("./blockchain/logger");
const efirRoutes=require("./routes/efir");
const tripRoutes = require("./routes/trips");



const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/users", userRoutes);
app.use("/api/emergency", emergencyRoutes);
app.use("/api/efir",efirRoutes);
app.use("/api/trips",tripRoutes);
app.use("/api", efirRoutes);


app.get("/", async (req, res) => {
  try {
    await db.collection("test").add({
      message: "Firebase connected successfully",
      time: new Date(),
    });

    res.send("Backend + Firebase connected successfully");
  } catch (error) {
    console.error(error);
    res.status(500).send("Firebase connection failed");
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
// ⏰ Run inactivity check every 5 minutes
setInterval(() => {
  checkInactivity().catch(console.error);
}, 5 * 60 * 1000);
logToBlockchain(
  "TEST_BACKEND_CONNECTED",
  "system",
  "render"
).catch(err => {
  console.error("Blockchain error:", err.message);
});
