import { Router } from "express";
import {
  createWorkoutPlan,
  getWorkoutPlans,
} from "../controllers/workout.controller";
import { authenticateToken } from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateToken);

router.post("/", createWorkoutPlan);
router.get("/", getWorkoutPlans);

export default router;
