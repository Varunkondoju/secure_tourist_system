require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { db } = require("./firebase");

const app = express();
app.use(cors());
app.use(express.json());

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
