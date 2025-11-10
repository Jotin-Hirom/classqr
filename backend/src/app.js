import express from "express";
import cors from "cors";

const app = express();
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

// Simple test route
app.get("/api/test", (req, res) => {
  res.json({ message: "Hello from Node backend 👋" });
});

export default app;
