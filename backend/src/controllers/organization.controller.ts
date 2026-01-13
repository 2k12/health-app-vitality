import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import { getCache, setCache, deleteCache } from "../utils/redis";

const prisma = new PrismaClient();

// Public: Get Branding Config by Slug or Host
export const getOrganizationConfig = async (req: Request, res: Response) => {
  try {
    const slug = (req.query.slug as string) || "fitba";
    const cacheKey = `organization:slug:${slug}`;

    const cachedOrg = await getCache(cacheKey);
    if (cachedOrg) {
      return res.json(cachedOrg);
    }

    const org = await prisma.organization.findUnique({
      where: { slug },
      select: {
        id: true,
        name: true,
        slug: true,
        primaryColor: true,
        secondaryColor: true,
        logoUrl: true,
        restaurantUrl: true,
        nutritionDetails: true,
      },
    });

    if (!org) {
      // Return default Fitba config
      // Do not cache the default response to allow for future org creation with this slug
      return res.json({
        name: "Fitba",
        slug: "fitba",
        primaryColor: "#10B981",
        secondaryColor: "#1F2937",
        logoUrl: null,
        restaurantUrl: "https://fitbafood.vercel.app/",
      });
    }

    await setCache(cacheKey, org, 3600);
    res.json(org);
  } catch (error) {
    console.error("Get Org Config error:", error);
    res.status(500).json({ message: "Error fetching configuration" });
  }
};

// Admin: Create Organization
export const createOrganization = async (req: Request, res: Response) => {
  try {
    const { name, slug, primaryColor, secondaryColor, logoUrl, restaurantUrl } =
      req.body;

    // Check if slug exists
    const existing = await prisma.organization.findUnique({ where: { slug } });
    if (existing)
      return res.status(400).json({ message: "Slug already exists" });

    const org = await prisma.organization.create({
      data: {
        name,
        slug,
        primaryColor,
        secondaryColor,
        logoUrl,
        restaurantUrl,
      },
    });

    await deleteCache("organization:all");
    res.status(201).json(org);
  } catch (error) {
    console.error("Create Org error:", error);
    res.status(500).json({ message: "Error creating organization" });
  }
};

// SuperAdmin: Get ALL Organizations
export const getAllOrganizations = async (req: Request, res: Response) => {
  try {
    const cacheKey = "organization:all";
    const cachedOrgs = await getCache(cacheKey);
    if (cachedOrgs) {
      return res.json(cachedOrgs);
    }

    const orgs = await prisma.organization.findMany({
      orderBy: { createdAt: "desc" },
    });

    await setCache(cacheKey, orgs, 3600);
    res.json(orgs);
  } catch (error) {
    console.error("Error fetching all organizations:", error);
    res.status(500).json({ message: "Error fetching organizations" });
  }
};

// SuperAdmin: Get Organization by ID
export const getOrganizationById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const cacheKey = `organization:id:${id}`;

    const cachedOrg = await getCache(cacheKey);
    if (cachedOrg) {
      return res.json(cachedOrg);
    }

    const org = await prisma.organization.findUnique({
      where: { id },
    });
    if (!org) {
      return res.status(404).json({ message: "Organization not found" });
    }

    await setCache(cacheKey, org, 3600);
    res.json(org);
  } catch (error) {
    console.error("Error fetching organization:", error);
    res.status(500).json({ message: "Error fetching organization" });
  }
};

// SuperAdmin: Update Organization
export const updateOrganization = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const {
      name,
      slug,
      primaryColor,
      secondaryColor,
      logoUrl,
      restaurantUrl,
      nutritionDetails,
    } = req.body;

    const updatedOrg = await prisma.organization.update({
      where: { id },
      data: {
        name,
        slug,
        primaryColor,
        secondaryColor,
        logoUrl,
        restaurantUrl,
        nutritionDetails,
      },
    });

    // Invalidate caches
    await deleteCache("organization:all");
    await deleteCache(`organization:id:${id}`);
    await deleteCache(`organization:slug:${updatedOrg.slug}`); // Clear new slug cache if it exists, ensures fresh data

    res.json(updatedOrg);
  } catch (error) {
    console.error("Error updating organization:", error);
    res.status(500).json({ message: "Error updating organization" });
  }
};
