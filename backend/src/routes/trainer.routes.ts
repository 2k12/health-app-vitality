import { Router } from "express";
import {
  getAssignedUsers,
  upsertWorkoutPlan,
  getUserPlan,
} from "../controllers/trainer.controller";
import { authenticateToken } from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateToken);

router.get("/users", getAssignedUsers);
router.post("/workout-plan", upsertWorkoutPlan);
router.get("/workout-plan/:userId", getUserPlan);

export default router;
