import { Router } from "express";
import {
  getAllExercises,
  getExercisesByMuscleGroup,
  createExercise,
  updateExercise,
  deleteExercise,
} from "../controllers/exercise.controller";
import {
  authenticateToken,
  authorizeRoles,
} from "../middleware/auth.middleware";

const router = Router();

// Public/User routes
router.get("/", authenticateToken, getAllExercises);
router.get("/muscle/:muscle", authenticateToken, getExercisesByMuscleGroup);

// Admin routes
router.post(
  "/",
  authenticateToken,
  authorizeRoles("ADMINISTRADOR"),
  createExercise
);
router.put(
  "/:id",
  authenticateToken,
  authorizeRoles("ADMINISTRADOR"),
  updateExercise
);
router.delete(
  "/:id",
  authenticateToken,
  authorizeRoles("ADMINISTRADOR"),
  deleteExercise
);

export default router;
