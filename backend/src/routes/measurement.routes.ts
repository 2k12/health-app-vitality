import { Router } from "express";
import {
  authenticateToken,
  authorizeRoles,
} from "../middleware/auth.middleware";
import {
  createMeasurement,
  getMeasurements,
  getMeasurementsByUser,
  getMonthlyProgress,
} from "../controllers/measurement.controller";

const router = Router();

router.use(authenticateToken); // Protect all routes

router.post("/", createMeasurement);
router.get("/progress", getMonthlyProgress); // Specific route first
router.get("/", getMeasurements);
router.get("/history", getMeasurements);
router.get(
  "/user/:id",
  authorizeRoles("ADMINISTRADOR", "ENTRENADOR"),
  getMeasurementsByUser
);

export default router;
