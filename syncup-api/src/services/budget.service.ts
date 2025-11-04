import fs from "fs";
import path from "path";
import { BudgetDoc, BudgetLine } from "../models/types";

const DB = path.join(__dirname, "..", "data", "sample.json");
type DBShape = { budgets: BudgetDoc[]; accounts: any[]; transactions: any[] };

function readDB(): DBShape {
  return JSON.parse(fs.readFileSync(DB, "utf-8"));
}
function writeDB(data: DBShape) {
  fs.writeFileSync(DB, JSON.stringify(data, null, 2));
}

export const BudgetService = {
  getBudget(month?: string) {
    const db = readDB();
    if (!month) return db.budgets[0];
    return db.budgets.find((b) => b.month === month) || db.budgets[0];
  },

  setBudget(month: string, lines: BudgetLine[]) {
    const db = readDB();
    const existing = db.budgets.find((b) => b.month === month);
    if (existing) existing.lines = lines;
    else db.budgets.push({ id: `b_${month}`, month, lines });
    writeDB(db);
    return db.budgets.find((b) => b.month === month)!;
  },
};

