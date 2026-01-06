import { Router } from "express";
import {
  getAllExercises,
  getExercisesByMuscleGroup,
} from "../controllers/exercise.controller";
import { authenticateToken } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticateToken, getAllExercises);
router.get("/muscle/:muscle", authenticateToken, getExercisesByMuscleGroup);

export default router;
