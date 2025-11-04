import { Router } from "express";
import { listTransactions } from "./transactions.controller";
export const transactionsRouter = Router();
transactionsRouter.get("/", listTransactions);

