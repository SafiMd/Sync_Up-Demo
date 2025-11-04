import { Router } from "express";
import { getBudget, setBudget } from "./budgets.controller";
export const budgetsRouter = Router();
budgetsRouter.get("/", getBudget);
budgetsRouter.put("/", setBudget);

