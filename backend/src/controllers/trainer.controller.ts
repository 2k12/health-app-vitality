import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import { deleteCache } from "../utils/redis";

const prisma = new PrismaClient();

export const getAssignedUsers = async (req: Request, res: Response) => {
  try {
    const trainerId = (req as any).user.userId;

    const assignedUsers = await prisma.user.findMany({
      where: {
        profile: {
          assignedTrainerId: trainerId,
        },
      },
      include: {
        profile: true,
        measurements: {
          orderBy: { date: "desc" },
          take: 1,
        },
      },
    });

    res.json(assignedUsers);
  } catch (error) {
    console.error("Get Assigned Users error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const upsertWorkoutPlan = async (req: Request, res: Response) => {
  try {
    const trainerId = (req as any).user.userId;
    const { userId, exercises } = req.body;

    // Check if a plan already exists for this user and trainer
    const existingPlan = await prisma.workoutPlan.findFirst({
      where: { userId, trainerId },
    });

    let plan;
    if (existingPlan) {
      plan = await prisma.workoutPlan.update({
        where: { id: existingPlan.id },
        data: { exercises },
      });
    } else {
      plan = await prisma.workoutPlan.create({
        data: {
          userId,
          trainerId,
          exercises,
        },
      });
    }

    // Sync User Profile Training Days
    let daysCount = 0;
    if (Array.isArray(exercises)) {
      daysCount = exercises.length;
    } else if (typeof exercises === "object") {
      daysCount = Object.keys(exercises).length;
    }

    if (daysCount > 0) {
      await prisma.userProfile.update({
        where: { userId },
        data: { trainingDays: daysCount },
      });
    }

    // Notify User
    await prisma.notification.create({
      data: {
        userId: userId, // Notify the CLIENT
        title: "Nueva Rutina Asignada",
        message: `Tu entrenador ha actualizado tu plan de entrenamiento. Ahora tienes una rutina de ${daysCount} días.`,
        type: "PLAN_UPDATE",
      },
    });

    // Invalidate User's Workout Cache
    await deleteCache(`workouts:user:${userId}`);

    res.status(200).json(plan);
  } catch (error) {
    console.error("Upsert WorkoutPlan error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getUserPlan = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const plan = await prisma.workoutPlan.findFirst({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });

    if (!plan) {
      return res.status(404).json({ message: "Plan not found" });
    }

    res.json(plan);
  } catch (error) {
    console.error("Get User Plan error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
