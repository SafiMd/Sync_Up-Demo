import fs from "fs";
import path from "path";
import { Request, Response } from "express";
const DB = path.join(__dirname, "..", "..", "data", "sample.json");

export function listTransactions(req: Request, res: Response) {
  const { accountId, category, from, to } = req.query;
  const db = JSON.parse(fs.readFileSync(DB, "utf-8"));
  let tx = db.transactions as any[];

  if (accountId) tx = tx.filter((t) => t.accountId === accountId);
  if (category) tx = tx.filter((t) => t.category === category);
  if (from) tx = tx.filter((t) => t.date >= String(from));
  if (to) tx = tx.filter((t) => t.date <= String(to));

  res.json(tx);
}

