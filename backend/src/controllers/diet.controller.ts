import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import { getCache, setCache, deleteCache } from "../utils/redis";

const prisma = new PrismaClient();

export const generateDietPlan = async (req: Request, res: Response) => {
  try {
    let userId = (req as any).user.userId;
    const userRole = (req as any).user.role;

    // Admin or Trainer can assign diet to specific user
    if (
      req.body.userId &&
      (userRole === "ADMINISTRADOR" || userRole === "ENTRENADOR")
    ) {
      userId = req.body.userId;
    }

    // 1. Get User's Latest Measurement for Targets
    const measurement = await prisma.userMeasurement.findFirst({
      where: { userId },
      orderBy: { date: "desc" },
    });

    let targetCalories = 2000; // Default fallback

    if (!measurement) {
      // 1.1 Fallback: Check User Profile
      const profile = await prisma.userProfile.findUnique({
        where: { userId },
      });

      if (!profile) {
        return res.status(404).json({
          message:
            "No se encontraron medidas ni perfil. Por favor completa tu perfil primero.",
        });
      }

      // Calculate BMR (Mifflin-St Jeor)
      const isMale = profile.gender === "MASCULINO";
      let bmr =
        10 * profile.weight +
        6.25 * profile.height -
        5 * profile.age +
        (isMale ? 5 : -161);

      // Activity Multiplier
      const activityMultipliers: Record<string, number> = {
        SEDENTARIO: 1.2,
        LIGERO: 1.375,
        MODERADO: 1.55,
        ACTIVO: 1.725,
        MUY_ACTIVO: 1.9,
      };
      const activity = profile.activityLevel || "SEDENTARIO";
      const tdee = bmr * (activityMultipliers[activity] || 1.2);

      // Goal Adjustment
      switch (profile.fitnessGoal) {
        case "PERDER_PESO":
          targetCalories = tdee - 500;
          break;
        case "GANAR_MUSCULO":
          targetCalories = tdee + 500;
          break;
        case "MANTENIMIENTO":
        default:
          targetCalories = tdee;
          break;
      }
    } else {
      targetCalories = measurement.targetCalories || 2000;
    }

    // Macro Split (approx 30% P, 40% C, 30% F)
    const targetProtein = (targetCalories * 0.3) / 4;
    const targetCarbs = (targetCalories * 0.4) / 4;
    const targetFats = (targetCalories * 0.3) / 9;

    // 2. Fetch Food Items
    const proteins = await prisma.foodItem.findMany({
      where: { category: "PROTEINA" },
    });
    const carbs = await prisma.foodItem.findMany({
      where: { category: "CARBOHIDRATO" },
    });
    const fats = await prisma.foodItem.findMany({
      where: { category: "GRASA" },
    });
    const veggies = await prisma.foodItem.findMany({
      where: { category: "VEGETAL" },
    });

    if (!proteins.length || !carbs.length || !fats.length) {
      return res.status(500).json({
        message:
          "Faltan alimentos en la base de datos (Proteína, Carb, Grasa).",
      });
    }

    // 3. Helper to pick random item
    const pick = (arr: any[]) => arr[Math.floor(Math.random() * arr.length)];

    // 4. Create Diet Plan Structure
    const plan = await prisma.dietPlan.create({
      data: {
        userId,
        dailyCalories: Math.round(targetCalories),
        proteinGrams: Math.round(targetProtein),
        carbohydrateGrams: Math.round(targetCarbs),
        fatGrams: Math.round(targetFats),
      },
    });

    // 5. Generate Meals (3 Meals)
    // 5. Generate Meals (3 Meals per day for 7 days)
    const mealDefinitions = [
      { name: "Desayuno", ratio: 0.3 },
      { name: "Almuerzo", ratio: 0.4 },
      { name: "Cena", ratio: 0.3 },
    ];

    let order = 1;
    // Loop for Days (1 to 7)
    for (let day = 1; day <= 7; day++) {
      for (const meal of mealDefinitions) {
        const mealCalories = targetCalories * meal.ratio;
        const mealProtein = targetProtein * meal.ratio;
        const mealCarbs = targetCarbs * meal.ratio;
        const mealFats = targetFats * meal.ratio;

        const createdMeal = await prisma.dietMeal.create({
          data: {
            dietPlanId: plan.id,
            name: meal.name,
            order: order++,
            day: day, // Save Day
          },
        });

        // Simple Logic: 1 Protein, 1 Carb, 1 Fat per meal + optional Veggie
        const pItem = pick(proteins);
        const cItem = pick(carbs);
        const fItem = pick(fats);

        // Calc portions (grams) = (Target Macro / Item Macro per 100g) * 100
        const pGrams = (mealProtein / pItem.protein) * 100;
        const cGrams = (mealCarbs / cItem.carbs) * 100;
        const fGrams = (mealFats / fItem.fat) * 100;

        await prisma.dietFood.create({
          data: {
            dietMealId: createdMeal.id,
            foodId: pItem.id,
            portionGram: Math.round(pGrams),
          },
        });
        await prisma.dietFood.create({
          data: {
            dietMealId: createdMeal.id,
            foodId: cItem.id,
            portionGram: Math.round(cGrams),
          },
        });
        await prisma.dietFood.create({
          data: {
            dietMealId: createdMeal.id,
            foodId: fItem.id,
            portionGram: Math.round(fGrams),
          },
        });

        // Add Veggie to Lunch/Dinner
        if (meal.name !== "Desayuno") {
          const vItem = pick(veggies);
          await prisma.dietFood.create({
            data: {
              dietMealId: createdMeal.id,
              foodId: vItem.id,
              portionGram: 100,
            },
          });
        }
      }
    }

    // 6. Return full plan with relations
    const fullPlan = await prisma.dietPlan.findUnique({
      where: { id: plan.id },
      include: {
        meals: {
          include: {
            foods: {
              include: { food: true },
            },
          },
          orderBy: { order: "asc" },
        },
      },
    });

    await deleteCache(`diet:latest:${userId}`);

    // Check if we used fallback (targetCalories was calculated from profile or default)
    const wasFallback = !measurement;

    res.json({
      plan: fullPlan,
      message: wasFallback
        ? "Plan generado basado en tu Perfil (No existen registros de medidas recientes)."
        : "Plan generado exitosamente basado en tu último control.",
    });
  } catch (error) {
    console.error("Generate DietPlan error:", error);
    res.status(500).json({ message: "Error interno del servidor" });
  }
};

export const createDietPlan = generateDietPlan; // Alias for compatibility if needed

export const getLatestDietPlan = async (req: Request, res: Response) => {
  try {
    let userId = (req as any).user.userId;
    const userRole = (req as any).user.role;

    if (
      req.query.userId &&
      (userRole === "ADMINISTRADOR" || userRole === "ENTRENADOR")
    ) {
      userId = req.query.userId as string;
    }

    const cacheKey = `diet:latest:${userId}`;

    const cachedPlan = await getCache(cacheKey);
    if (cachedPlan) {
      return res.json(cachedPlan);
    }

    const plan = await prisma.dietPlan.findFirst({
      where: { userId },
      orderBy: { createdAt: "desc" },
      include: {
        meals: {
          include: {
            foods: {
              include: { food: true },
            },
          },
          orderBy: { order: "asc" },
        },
      },
    });

    if (plan) {
      await setCache(cacheKey, plan, 3600);
    }

    res.json(plan);
  } catch (error) {
    console.error("Get DietPlan error:", error);
    res.status(500).json({ message: "Error interno del servidor" });
  }
};

export const getDietPlans = getLatestDietPlan; // Redirect to latest detail for now

// Add Food to Meal (Admin/Trainer)
export const addFoodToMeal = async (req: Request, res: Response) => {
  try {
    const { dietMealId } = req.params;
    const { foodId, portionGram } = req.body;

    // Validate inputs
    if (!foodId || !portionGram) {
      return res
        .status(400)
        .json({ message: "Se requiere ID de alimento y porción" });
    }

    const dietFood = await prisma.dietFood.create({
      data: {
        dietMealId,
        foodId,
        portionGram: parseInt(portionGram),
      },
      include: { food: true },
    });

    // Invalidate Cache (Find owner of this meal to invalidate correct key)
    // Complex to find owner efficiently without query, but we can just clear all or try to lookup
    const meal = await prisma.dietMeal.findUnique({
      where: { id: dietMealId },
      include: { dietPlan: true },
    });
    if (meal) {
      await deleteCache(`diet:latest:${meal.dietPlan.userId}`);
    }

    res.json(dietFood);
  } catch (error) {
    console.error("Add Food error:", error);
    res.status(500).json({ message: "Error al agregar alimento" });
  }
};

// Remove Food from Meal
export const removeFoodFromMeal = async (req: Request, res: Response) => {
  try {
    const { id } = req.params; // dietFoodId

    // Get info before delete for cache invalidation
    const dietFood = await prisma.dietFood.findUnique({
      where: { id },
      include: { dietMeal: { include: { dietPlan: true } } },
    });

    if (!dietFood)
      return res
        .status(404)
        .json({ message: "Entrada de alimento no encontrada" });

    await prisma.dietFood.delete({ where: { id } });

    if (dietFood.dietMeal?.dietPlan?.userId) {
      await deleteCache(`diet:latest:${dietFood.dietMeal.dietPlan.userId}`);
    }

    res.json({ message: "Alimento eliminado" });
  } catch (error) {
    console.error("Remove Food error:", error);
    res.status(500).json({ message: "Error al eliminar alimento" });
  }
};
