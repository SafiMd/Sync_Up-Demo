import { Request, Response } from "express";
import { PlaidService } from "../../services/plaid.service";

export function createLinkToken(req: Request, res: Response) {
  const { userId = "demo" } = req.body || {};
  res.json(PlaidService.createLinkToken(userId));
}

export function exchangePublicToken(req: Request, res: Response) {
  const { public_token } = req.body || {};
  if (!public_token) return res.status(400).json({ error: "public_token required" });
  res.json(PlaidService.exchangePublicToken(public_token));
}

