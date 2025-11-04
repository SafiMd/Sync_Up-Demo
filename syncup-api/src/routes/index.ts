import { Router } from "express";
import { accountsRouter } from "../v1/accounts/accounts.routes";
import { transactionsRouter } from "../v1/transactions/transactions.routes";
import { budgetsRouter } from "../v1/budgets/budgets.routes";
import { insightsRouter } from "../v1/insights/insights.routes";
import { plaidRouter } from "../v1/plaid/plaid.routes";

export const api = Router();
api.get("/health", (_req, res) => res.json({ ok: true }));
api.use("/accounts", accountsRouter);
api.use("/transactions", transactionsRouter);
api.use("/budgets", budgetsRouter);
api.use("/insights", insightsRouter);
api.use("/plaid", plaidRouter);

