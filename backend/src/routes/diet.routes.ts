import { Router } from "express";
import {
  createDietPlan,
  getDietPlans,
  addFoodToMeal,
  removeFoodFromMeal,
} from "../controllers/diet.controller";
import { authenticateToken } from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateToken);

router.post("/", createDietPlan);
router.get("/", getDietPlans);
router.post("/:dietMealId/food", addFoodToMeal);
router.delete("/food/:id", removeFoodFromMeal);

export default router;
