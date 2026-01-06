import { Router } from "express";
import {
  getAllFoods,
  createFood,
  updateFood,
  deleteFood,
} from "../controllers/food.controller";
import {
  authenticateToken,
  authorizeRoles,
} from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateToken);

// Public-ish (authenticated users can see foods? Yes, for diet logging)
router.get("/", getAllFoods);

// Admin only (manage foods)
router.post("/", authorizeRoles("ADMINISTRADOR"), createFood);
router.put("/:id", authorizeRoles("ADMINISTRADOR"), updateFood);
router.delete("/:id", authorizeRoles("ADMINISTRADOR"), deleteFood);

export default router;
