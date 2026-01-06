import { Router } from "express";
import {
  register,
  login,
  acceptTerms,
  getMe,
} from "../controllers/auth.controller";
import { authenticateToken } from "../middleware/auth.middleware";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.get("/me", authenticateToken, getMe);
router.post("/accept-terms", authenticateToken, acceptTerms);

export default router;
