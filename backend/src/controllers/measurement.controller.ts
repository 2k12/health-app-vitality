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

// Helper to calculate Body Fat (Navy Method)
const calculateBodyFat = (
  gender: Gender,
  waist: number,
  neck: number,
  height: number,
  hips: number
) => {
  if (waist === 0 || neck === 0 || height === 0) return 0;

  // Formulas typically use logs of measurements in CM
  // Men: 495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450
  // Women: 495 / (1.29579 - 0.35004 * log10(waist + hips - neck) + 0.22100 * log10(height)) - 450

  try {
    if (gender === "MASCULINO") {
      return (
        495 /
          (1.0324 -
            0.19077 * Math.log10(waist - neck) +
            0.15456 * Math.log10(height)) -
        450
      );
    } else {
      if (hips === 0) return 0;
      return (
        495 /
          (1.29579 -
            0.35004 * Math.log10(waist + hips - neck) +
            0.221 * Math.log10(height)) -
        450
      );
    }
  } catch (e) {
    return 0; // Return 0 if calculation fails (e.g. log of negative)
  }
};

export const createMeasurement = async (req: Request, res: Response) => {
  try {
    const userId = req.user.userId;
    const {
      age,
      gender,
      heightCm,
      weightKg,
      goal,
      trainingDays,
      neck,
      chest,
      arm,
      waist,
      hips,
      glute,
      leg,
      // Optional overrides
      bodyFat: providedBodyFat,
      bmr: providedBMR,
      tdee: providedTDEE,
      targetCalories: providedTarget,
    } = req.body;

    // 0. Fetch Current Profile to respect Goal/Strategy
    const currentProfile = await prisma.userProfile.findUnique({
      where: { userId },
    });

    // 1. Parse Inputs (Safety)
    const pAge = age ? parseInt(age) : currentProfile?.age || 25;
    const pHeight = heightCm
      ? parseFloat(heightCm)
      : currentProfile?.height || 170;
    const pWeight = weightKg
      ? parseFloat(weightKg)
      : currentProfile?.weight || 70;
    const pWaist = waist ? parseFloat(waist) : 0;
    const pNeck = neck ? parseFloat(neck) : 0;
    const pHips = hips ? parseFloat(hips) : 0;
    // Do NOT override training days from measurement form usually, unless distinct.
    // We'll stick to Profile's training days for TDEE to be consistent.
    const pTrainingDays =
      currentProfile?.trainingDays ||
      (trainingDays ? parseInt(trainingDays) : 3);

    // Gender likely doesn't change, but if provided in measurement we might take it or profile's
    const pGender = currentProfile?.gender
      ? currentProfile.gender
      : mapGender(gender);

    // Goal Strategy: STRICTLY from Profile if exists
    let pGoal: UserGoal = UserGoal.MANTENIMIENTO;
    if (currentProfile) {
      // Map Profile Enum to Controller Logic
      if (currentProfile.fitnessGoal === "GANAR_MUSCULO")
        pGoal = UserGoal.VOLUMEN;
      else if (currentProfile.fitnessGoal === "PERDER_PESO")
        pGoal = UserGoal.DEFINICION;
      else pGoal = UserGoal.MANTENIMIENTO;
    } else {
      // Fallback for first time measure if no profile
      pGoal = mapGoal(goal);
    }

    // 2. Calculate Body Fat if not provided
    let finalBodyFat = providedBodyFat ? parseFloat(providedBodyFat) : 0;
    if (!finalBodyFat && pWaist > 0 && pNeck > 0 && pHeight > 0) {
      const calculated = calculateBodyFat(
        pGender,
        pWaist,
        pNeck,
        pHeight,
        pHips
      );
      if (!isNaN(calculated) && calculated > 0) {
        finalBodyFat = parseFloat(calculated.toFixed(1));
      }
    }

    // 3. Calculate BMR (Mifflin-St Jeor)
    // Men: 10W + 6.25H - 5A + 5
    // Women: 10W + 6.25H - 5A - 161
    let calcBMR = 0;
    if (pGender === "MASCULINO") {
      calcBMR = 10 * pWeight + 6.25 * pHeight - 5 * pAge + 5;
    } else {
      calcBMR = 10 * pWeight + 6.25 * pHeight - 5 * pAge - 161;
    }

    // 4. Calculate TDEE
    // Multipliers: 0->1.2, 1-2->1.375, 3-4->1.55, 5-6->1.725, 7->1.9
    let activityMult = 1.2;
    if (pTrainingDays >= 1 && pTrainingDays <= 2) activityMult = 1.375;
    else if (pTrainingDays >= 3 && pTrainingDays <= 4) activityMult = 1.55;
    else if (pTrainingDays >= 5 && pTrainingDays <= 6) activityMult = 1.725;
    else if (pTrainingDays >= 7) activityMult = 1.9;

    const calcTDEE = calcBMR * activityMult;

    // 5. Calculate Target Calories & Macros
    let targetCals = calcTDEE;
    if (pGoal === "VOLUMEN") targetCals += 300; // Surplus
    else if (pGoal === "DEFINICION") targetCals -= 400; // Deficit

    // Macro Split (Rough Estimate)
    // Protein: 2g per kg bodyweight
    const proteinGrams = Math.round(pWeight * 2.0);
    // Fat: 0.9g per kg
    const fatGrams = Math.round(pWeight * 0.9);
    // Carbs: Remainder
    const proteinInc = proteinGrams * 4;
    const fatInc = fatGrams * 9;
    const remainingCals = targetCals - (proteinInc + fatInc);
    const carbGrams = Math.max(0, Math.round(remainingCals / 4));

    // Final numeric values for DB
    const finalBMR = parseFloat(calcBMR.toFixed(0));
    const finalTDEE = parseFloat(calcTDEE.toFixed(0));
    const finalTargetCals = parseFloat(targetCals.toFixed(0));

    // 6. Create Measurement Record
    const measurement = await prisma.userMeasurement.create({
      data: {
        userId,
        age: pAge,
        gender: pGender,
        heightCm: pHeight,
        weightKg: pWeight,
        goal: pGoal,
        trainingDays: pTrainingDays,

        neck: pNeck,
        chest: chest ? parseFloat(chest) : 0,
        arm: arm ? parseFloat(arm) : 0,
        waist: pWaist,
        hips: pHips,
        glute: glute ? parseFloat(glute) : 0,
        leg: leg ? parseFloat(leg) : 0,

        bodyFat: finalBodyFat,
        bmr: finalBMR,
        tdee: finalTDEE,
        targetCalories: finalTargetCals,
      },
    });

    // 7. SYNC: Update UserProfile (Partially)
    // ONLY update biometrics (Weight, BodyFat logic if we had it, etc).
    // DO NOT update fitnessGoal or trainingDays.
    await prisma.userProfile.update({
      where: { userId },
      data: {
        age: pAge,
        height: pHeight,
        weight: pWeight,
        // gender: pGender, // Optionally update gender if it was "OTRO" and now defined
      },
    });

    // 8. SYNC: Update or Create DietPlan
    // Check if diet plan exists
    const existingDiet = await prisma.dietPlan.findFirst({ where: { userId } });

    if (existingDiet) {
      await prisma.dietPlan.update({
        where: { id: existingDiet.id },
        data: {
          dailyCalories: Math.round(finalTargetCals),
          proteinGrams: proteinGrams,
          fatGrams: fatGrams,
          carbohydrateGrams: carbGrams,
        },
      });
    } else {
      await prisma.dietPlan.create({
        data: {
          userId,
          dailyCalories: Math.round(finalTargetCals),
          proteinGrams: proteinGrams,
          fatGrams: fatGrams,
          carbohydrateGrams: carbGrams,
        },
      });
    }

    await deleteCache(`measurements:user:${userId}`);
    await deleteCache(`profile:user:${userId}`);
    // Also invalidate diet cache if it exists
    await deleteCache(`diet:user:${userId}`);

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

export const getMonthlyProgress = async (req: Request, res: Response) => {
  try {
    const userId = req.user.userId;
    const currentYear = new Date().getFullYear();
    const cacheKey = `progress:user:${userId}:${currentYear}`;

    const cachedProgress = await getCache(cacheKey);
    if (cachedProgress) {
      return res.json(cachedProgress);
    }

    const startOfYear = new Date(currentYear, 0, 1);
    const endOfYear = new Date(currentYear, 11, 31);

    const measurements = await prisma.userMeasurement.findMany({
      where: {
        userId,
        date: {
          gte: startOfYear,
          lte: endOfYear,
        },
      },
      orderBy: { date: "asc" },
    });

    // Process data: one point per month (latest)
    const monthlyData = Array(12)
      .fill(null)
      .map((_, i) => ({
        name: new Date(0, i).toLocaleString("default", { month: "short" }),
        weight: 0,
        bodyFat: 0,
        hasData: false,
      }));

    measurements.forEach((m) => {
      const month = m.date.getMonth();
      // Update with latest value found for that month (since ordered by asc, last one wins)
      monthlyData[month].weight = m.weightKg;
      monthlyData[month].bodyFat = m.bodyFat || 0;
      monthlyData[month].hasData = true;
    });

    // Filter out months without data or keep them? keeping them might be good for chart axis,
    // but typically we might only want to show lines for valid data.
    // For recharts, 0 is a valid value, better to return all months or just non-empty?
    // Let's return only months up to the current month or all?
    // Returning all allows the chart to show the full year timeline.

    await setCache(cacheKey, monthlyData, 3600);
    res.json(monthlyData);
  } catch (error) {
    console.error("Get monthly progress error:", error);
    res.status(500).json({ message: "Failed to fetch progress" });
  }
};
