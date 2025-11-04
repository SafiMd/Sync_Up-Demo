import "dotenv/config";
export const CONFIG = {
  port: Number(process.env.PORT || 4000),
  nodeEnv: process.env.NODE_ENV || "development",
  demoToken: process.env.DEMO_TOKEN || "syncup-demo-token",
};

