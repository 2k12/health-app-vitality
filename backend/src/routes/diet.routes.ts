import { Router } from "express";
import { createDietPlan, getDietPlans } from "../controllers/diet.controller";
import { authenticateToken } from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateToken);

router.post("/", createDietPlan);
router.get("/", getDietPlans);

export default router;
