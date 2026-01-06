import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import { getCache, setCache, deleteCache } from "../utils/redis";

const prisma = new PrismaClient();

export const createWorkoutPlan = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;
    const { trainerId, exercises } = req.body;

    const plan = await prisma.workoutPlan.create({
      data: {
        userId,
        trainerId,
        exercises: exercises, // Json type in Prisma
      },
    });

    await deleteCache(`workouts:user:${userId}`);
    res.status(201).json(plan);
  } catch (error) {
    console.error("Create WorkoutPlan error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getWorkoutPlans = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;
    const cacheKey = `workouts:user:${userId}`;

    const cachedPlans = await getCache(cacheKey);
    if (cachedPlans) {
      return res.json(cachedPlans);
    }

    const plans = await prisma.workoutPlan.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });

    await setCache(cacheKey, plans, 3600);
    res.json(plans);
  } catch (error) {
    console.error("Get WorkoutPlans error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
