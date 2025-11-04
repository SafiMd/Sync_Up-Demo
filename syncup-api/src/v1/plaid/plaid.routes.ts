import { Router } from "express";
import { createLinkToken, exchangePublicToken } from "./plaid.controller";
export const plaidRouter = Router();
plaidRouter.post("/link/token/create", createLinkToken);
plaidRouter.post("/item/public_token/exchange", exchangePublicToken);

