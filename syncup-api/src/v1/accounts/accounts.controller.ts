import fs from "fs";
import path from "path";
import { Request, Response } from "express";
const DB = path.join(__dirname, "..", "..", "data", "sample.json");

export function listAccounts(_req: Request, res: Response) {
  const db = JSON.parse(fs.readFileSync(DB, "utf-8"));
  res.json(db.accounts);
}

