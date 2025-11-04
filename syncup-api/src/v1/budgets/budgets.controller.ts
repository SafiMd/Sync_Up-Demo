import { Request, Response } from "express";
import { BudgetService } from "../../services/budget.service";

export function getBudget(req: Request, res: Response) {
  const { month } = req.query as { month?: string };
  res.json(BudgetService.getBudget(month));
}

export function setBudget(req: Request, res: Response) {
  const { month, lines } = req.body as { month: string; lines: any[] };
  const saved = BudgetService.setBudget(month, lines);
  res.json(saved);
}

