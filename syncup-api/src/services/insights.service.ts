import { parseISO, isWithinInterval } from "date-fns";
import fs from "fs";
import path from "path";
import { BudgetDoc, Transaction } from "../models/types";

const DB = path.join(__dirname, "..", "data", "sample.json");
type DBShape = { budgets: BudgetDoc[]; accounts: any[]; transactions: Transaction[] };

function readDB(): DBShape {
  return JSON.parse(fs.readFileSync(DB, "utf-8"));
}

export function calculateInsights(month: string) {
  const db = readDB();
  const budget = db.budgets.find((b) => b.month === month) || db.budgets[0];

  const start = parseISO(month + "-01");
  const end = new Date(start.getFullYear(), start.getMonth() + 1, 0);

  const inMonth = db.transactions.filter((t) => {
    const d = parseISO(t.date);
    return isWithinInterval(d, { start, end });
  });

  const byCategory: Record<string, { spent: number; count: number }> = {};
  for (const t of inMonth) {
    const cat = t.category;
    if (!byCategory[cat]) byCategory[cat] = { spent: 0, count: 0 };
    if (t.amount < 0) byCategory[cat].spent += Math.abs(t.amount);
    byCategory[cat].count += 1;
  }

  const income = inMonth.filter((t) => t.amount > 0).reduce((s, t) => s + t.amount, 0);
  const expenses = inMonth.filter((t) => t.amount < 0).reduce((s, t) => s + Math.abs(t.amount), 0);
  const net = income - expenses;

  const lines = budget.lines.map((line) => {
    const spent = byCategory[line.category]?.spent || 0;
    const limit = income * line.monthlyLimit;
    const usagePct = limit > 0 ? (spent / limit) * 100 : 0;
    let status: "good" | "moderate" | "warning" | "over";
    if (usagePct < 60) status = "good";
    else if (usagePct < 80) status = "moderate";
    else if (usagePct <= 100) status = "warning";
    else status = "over";
    return {
      category: line.category,
      spent,
      limit,
      usagePct,
      status,
      count: byCategory[line.category]?.count || 0,
    };
  });

  return {
    month,
    income,
    expenses,
    net,
    categories: lines.sort((a, b) => b.spent - a.spent),
  };
}

