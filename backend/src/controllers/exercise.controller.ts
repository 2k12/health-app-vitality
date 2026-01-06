import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import { getCache, setCache } from "../utils/redis";

const prisma = new PrismaClient();

export const getAllExercises = async (req: Request, res: Response) => {
  try {
    const cacheKey = "exercises:all";
    const cachedExercises = await getCache(cacheKey);
    if (cachedExercises) {
      return res.json(cachedExercises);
    }

    const exercises = await prisma.exercise.findMany({
      orderBy: { name: "asc" },
    });
    await setCache(cacheKey, exercises, 3600);
    res.json(exercises);
  } catch (error) {
    console.error("Get All Exercises error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getExercisesByMuscleGroup = async (
  req: Request,
  res: Response
) => {
  try {
    const { muscle } = req.params;
    const cacheKey = `exercises:muscle:${muscle}`;
    const cachedExercises = await getCache(cacheKey);
    if (cachedExercises) {
      return res.json(cachedExercises);
    }

    const exercises = await prisma.exercise.findMany({
      where: { muscleGroup: muscle },
      orderBy: { name: "asc" },
    });
    await setCache(cacheKey, exercises, 3600);
    res.json(exercises);
  } catch (error) {
    res.status(500).json({ message: "Internal server error" });
  }
};
