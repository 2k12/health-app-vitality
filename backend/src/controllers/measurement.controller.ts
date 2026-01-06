import { Request, Response } from "express";
import { PrismaClient, Gender, UserGoal } from "@prisma/client";
import { getCache, setCache, deleteCache } from "../utils/redis";

const prisma = new PrismaClient();

const mapGender = (val: any): Gender => {
  if (val === 0 || val === "MALE" || val === "MASCULINO")
    return Gender.MASCULINO;
  if (val === 1 || val === "FEMALE" || val === "FEMENINO")
    return Gender.FEMENINO;
  return Gender.OTRO;
};

const mapGoal = (val: any): UserGoal => {
  if (val === 0 || val === "GAIN" || val === "VOLUMEN") return UserGoal.VOLUMEN;
  if (val === 1 || val === "DEFINITION" || val === "DEFINICION")
    return UserGoal.DEFINICION;
  return UserGoal.MANTENIMIENTO;
};

export const createMeasurement = async (req: Request, res: Response) => {
  try {
    const userId = req.user.userId;
    const {
      // Bio
      age,
      gender,
      heightCm,
      weightKg,
      // Goal & Activity
      goal,
      trainingDays,
      // Measurements
      neck,
      chest,
      arm,
      waist,
      hips,
      glute,
      leg,
      // Computed
      bodyFat,
      bmr,
      tdee,
      targetCalories,
    } = req.body;

    // VALIDATION: One measurement per month
    // const now = new Date();
    // const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    // const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    // const existingMeasurement = await prisma.userMeasurement.findFirst({
    //   where: {
    //     userId,
    //     date: {
    //       gte: startOfMonth,
    //       lte: endOfMonth,
    //     },
    //   },
    // });

    // if (existingMeasurement) {
    //   return res
    //     .status(400)
    //     .json({ message: "Solo se permite un registro de medidas por mes." });
    // }

    const measurement = await prisma.userMeasurement.create({
      data: {
        userId,
        // Bio
        age: age ? parseInt(age) : 0,
        gender: mapGender(gender),
        heightCm: heightCm ? parseFloat(heightCm) : 0,
        weightKg: weightKg ? parseFloat(weightKg) : 0,

        // Goal
        goal: mapGoal(goal),
        trainingDays: trainingDays ? parseInt(trainingDays) : 0,

        // Measurements
        neck: neck ? parseFloat(neck) : 0,
        chest: chest ? parseFloat(chest) : 0,
        arm: arm ? parseFloat(arm) : 0,
        waist: waist ? parseFloat(waist) : 0,
        hips: hips ? parseFloat(hips) : 0,
        glute: glute ? parseFloat(glute) : 0,
        leg: leg ? parseFloat(leg) : 0,

        // Computed
        bodyFat: bodyFat ? parseFloat(bodyFat) : null,
        bmr: bmr ? parseFloat(bmr) : null,
        tdee: tdee ? parseFloat(tdee) : null,
        targetCalories: targetCalories ? parseFloat(targetCalories) : null,
      },
    });

    // SYNC: Update UserProfile with latest stats
    // Map UserGoal to FitnessGoal for profile
    let mappedFitnessGoal = "MANTENIMIENTO"; // Default
    const mGoal = mapGoal(goal);
    if (mGoal === "VOLUMEN") mappedFitnessGoal = "GANAR_MUSCULO";
    else if (mGoal === "DEFINICION") mappedFitnessGoal = "PERDER_PESO";
    // MANTENIMIENTO stays MANTENIMIENTO

    // Map Gender properly for Profile (Prisma Types should match if mapped correctly)
    const mGender = mapGender(gender);

    await prisma.userProfile.update({
      where: { userId },
      data: {
        age: age ? parseInt(age) : undefined,
        height: heightCm ? parseFloat(heightCm) : undefined,
        weight: weightKg ? parseFloat(weightKg) : undefined,
        gender: mGender,
        fitnessGoal: mappedFitnessGoal as any, // Cast because they share string values but are different enums
      },
    });

    await deleteCache(`measurements:user:${userId}`);
    await deleteCache(`profile:user:${userId}`); // Profile syncs with latest measurement
    res.status(201).json(measurement);
  } catch (error) {
    console.error("Create measurement error:", error);
    res.status(500).json({ message: "Failed to save measurement" });
  }
};

export const getMeasurements = async (req: Request, res: Response) => {
  try {
    const userId = req.user.userId;
    const cacheKey = `measurements:user:${userId}`;

    const cachedMeasurements = await getCache(cacheKey);
    if (cachedMeasurements) {
      return res.json(cachedMeasurements);
    }

    const measurements = await prisma.userMeasurement.findMany({
      where: { userId },
      orderBy: { date: "desc" },
    });

    await setCache(cacheKey, measurements, 3600);
    res.json(measurements);
  } catch (error) {
    console.error("Get measurements error:", error);
    res.status(500).json({ message: "Failed to fetch history" });
  }
};
export const getMeasurementsByUser = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    // For now, allow any authenticated user to see any measurements
    // In production, check if the requester is the user's trainer.
    const measurements = await prisma.userMeasurement.findMany({
      where: { userId: id },
      orderBy: { date: "desc" },
    });

    res.json(measurements);
  } catch (error) {
    console.error("Get measurements by user error:", error);
    res.status(500).json({ message: "Failed to fetch history" });
  }
};
