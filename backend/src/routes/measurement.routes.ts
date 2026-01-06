import { Router } from "express";
import {
  authenticateToken,
  authorizeRoles,
} from "../middleware/auth.middleware";
import {
  createMeasurement,
  getMeasurements,
  getMeasurementsByUser,
} from "../controllers/measurement.controller";

const router = Router();

router.use(authenticateToken); // Protect all routes

router.post("/", createMeasurement);
router.get("/history", getMeasurements);
router.get(
  "/user/:id",
  authorizeRoles("ADMINISTRADOR", "ENTRENADOR"),
  getMeasurementsByUser
);

export default router;
