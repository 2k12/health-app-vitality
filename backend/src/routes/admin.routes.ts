import { Router } from "express";
import {
  getAllUsers,
  getAllTrainers,
  assignTrainer,
  toggleUserStatus,
  createUser,
  updateUser,
  getUserById,
} from "../controllers/admin.controller";
import {
  authenticateToken,
  authorizeRoles,
} from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateToken);
router.use(authorizeRoles("ADMINISTRADOR")); // All routes here are Admin only

router.get("/users", getAllUsers);
router.get("/trainers", getAllTrainers);
router.post("/assign-trainer", assignTrainer);
router.post("/users", createUser);
router.get("/users/:id", getUserById);
router.put("/users/:id", updateUser);
router.patch("/users/:id/status", toggleUserStatus);

export default router;
