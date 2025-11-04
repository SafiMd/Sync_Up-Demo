import { Request, Response, NextFunction } from "express";
import { CONFIG } from "../config/env";

export function demoAuth(_req: Request, _res: Response, next: NextFunction) {
  // Open in dev; add real auth later (Firebase/JWT)
  if (CONFIG.nodeEnv === "development") return next();
  // For prod: simple token check
  // const header = _req.headers.authorization || "";
  // const token = header.startsWith("Bearer ") ? header.slice(7) : "";
  // if (token !== CONFIG.demoToken) return _res.status(401).json({ error: "Unauthorized" });
  return next();
}

