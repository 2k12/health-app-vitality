import { Router } from "express";
import {
  getOrganizationConfig,
  createOrganization,
  getAllOrganizations,
  getOrganizationById,
  updateOrganization,
} from "../controllers/organization.controller";
import {
  authenticateToken,
  authorizeRoles,
} from "../middleware/auth.middleware";

const router = Router();

// Public route
router.get("/config", getOrganizationConfig);

// SuperAdmin Routes
router.use(authenticateToken); // Apply auth to all below
router.use(authorizeRoles("SUPERADMIN")); // Restrict to SuperAdmin

router.get("/", getAllOrganizations);
router.post("/", createOrganization);
router.get("/:id", getOrganizationById);
router.put("/:id", updateOrganization);

export default router;
