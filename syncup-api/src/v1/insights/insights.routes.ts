import { Router } from "express";
import { getInsights } from "./insights.controller";
export const insightsRouter = Router();
insightsRouter.get("/", getInsights);

