import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import { getCache, setCache, deleteCache } from "../utils/redis";

const prisma = new PrismaClient();

export const getProfile = async (req: Request, res: Response) => {
  try {
    const userId = req.user.userId;
    const cacheKey = `profile:user:${userId}`;

    const cachedProfile = await getCache(cacheKey);
    if (cachedProfile) {
      return res.json(cachedProfile);
    }

    const profile = await prisma.userProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            name: true,
            email: true,
          },
        },
      },
    });

    if (!profile) {
      return res.status(404).json({ message: "Profile not found" });
    }

    await setCache(cacheKey, profile, 3600);
    res.json(profile);
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const userId = req.user.userId;
    const { name, age, gender, height, weight, activityLevel, fitnessGoal } =
      req.body;

    // Update User name
    if (name) {
      await prisma.user.update({
        where: { id: userId },
        data: { name },
      });
    }

    // Update UserProfile
    const profile = await prisma.userProfile.update({
      where: { userId },
      data: {
        age: age ? parseInt(age) : undefined,
        gender,
        height: height ? parseFloat(height) : undefined,
        weight: weight ? parseFloat(weight) : undefined,
        activityLevel,
        fitnessGoal,
      },
    });

    await deleteCache(`profile:user:${userId}`);
    res.json(profile);
  } catch (error) {
    console.error("Update profile error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
