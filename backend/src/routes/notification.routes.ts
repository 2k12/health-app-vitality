import { Router } from "express";
import {
  getUserNotifications,
  markAsRead,
  markAllAsRead,
} from "../controllers/notification.controller";
import { authenticateToken } from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateToken); // Protect all routes

router.get("/", getUserNotifications);
router.patch("/:id/read", markAsRead);
router.patch("/read-all", markAllAsRead);

export default router;
