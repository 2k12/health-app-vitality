import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import { getCache, setCache, deleteCache } from "../utils/redis";

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

// Admin Operations
export const createExercise = async (req: Request, res: Response) => {
  try {
    const { name, muscleGroup, bodyPart } = req.body;
    const exercise = await prisma.exercise.create({
      data: { name, muscleGroup, bodyPart },
    });
    await deleteCache("exercises:all");
    res.status(201).json(exercise);
  } catch (error) {
    console.error("Create Exercise error:", error);
    res.status(500).json({ message: "Error creating exercise" });
  }
};

export const updateExercise = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, muscleGroup, bodyPart } = req.body;
    const exercise = await prisma.exercise.update({
      where: { id },
      data: { name, muscleGroup, bodyPart },
    });
    await deleteCache("exercises:all");
    res.json(exercise);
  } catch (error) {
    console.error("Update Exercise error:", error);
    res.status(500).json({ message: "Error updating exercise" });
  }
};

export const deleteExercise = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.exercise.delete({ where: { id } });
    await deleteCache("exercises:all");
    res.json({ message: "Exercise deleted" });
  } catch (error) {
    console.error("Delete Exercise error:", error);
    res.status(500).json({ message: "Error deleting exercise" });
  }
};
