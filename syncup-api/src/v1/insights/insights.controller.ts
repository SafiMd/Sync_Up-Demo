import { Request, Response } from "express";
import { calculateInsights } from "../../services/insights.service";

export function getInsights(req: Request, res: Response) {
  const { month = new Date().toISOString().slice(0, 7) } = req.query as { month?: string };
  res.json(calculateInsights(month));
}

