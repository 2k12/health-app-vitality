import { Router } from "express";
import { authenticateToken } from "../middleware/auth.middleware";
import { getProfile, updateProfile } from "../controllers/profile.controller";

const router = Router();

router.use(authenticateToken);

router.get("/", getProfile);
router.put("/", updateProfile);

export default router;
