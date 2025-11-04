import { Router } from "express";
import { listAccounts } from "./accounts.controller";
export const accountsRouter = Router();
accountsRouter.get("/", listAccounts);

