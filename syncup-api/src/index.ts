import express from "express";
import cors from "cors";
import morgan from "morgan";
import { api } from "./routes";
import { demoAuth } from "./middleware/auth";
import { CONFIG } from "./config/env";

const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

app.use(demoAuth);
app.use("/v1", api);

app.use((err: any, _req: any, res: any, _next: any) => {
  const status = err.status || 500;
  res.status(status).json({ error: err.message || "Internal Server Error" });
});

app.listen(CONFIG.port, () => {
  console.log(`SyncUp API listening on http://localhost:${CONFIG.port}`);
});

