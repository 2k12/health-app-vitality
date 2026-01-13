import {
  PrismaClient,
  Gender,
  Role,
  ActivityLevel,
  FitnessGoal,
  UserGoal,
} from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const commonPassword = "password123";
  const passwordHash = await bcrypt.hash(commonPassword, 10);

  const usersData = [
    {
      email: "usuario@ejemplo.com",
      name: "Usuario Estándar",
      role: Role.USUARIO,
      profile: {
        age: 25,
        gender: Gender.FEMENINO,
        height: 165,
        weight: 60,
        activityLevel: ActivityLevel.ACTIVO,
        fitnessGoal: FitnessGoal.MANTENIMIENTO,
      },
    },
    {
      email: "trainer@ejemplo.com",
      name: "Entrenador Pro",
      role: Role.ENTRENADOR,
      profile: {
        age: 32,
        gender: Gender.MASCULINO,
        height: 180,
        weight: 85,
        activityLevel: ActivityLevel.ACTIVO,
        fitnessGoal: FitnessGoal.GANAR_MUSCULO,
      },
    },
    {
      email: "admin@ejemplo.com",
      name: "Administrador Sistema",
      role: Role.ADMINISTRADOR,
      profile: {
        age: 40,
        gender: Gender.MASCULINO,
        height: 175,
        weight: 80,
        activityLevel: ActivityLevel.MODERADO,
        fitnessGoal: FitnessGoal.MANTENIMIENTO,
      },
    },
  ];

  for (const userData of usersData) {
    const existingUser = await prisma.user.findUnique({
      where: { email: userData.email },
    });

    if (existingUser) {
      console.log(`User ${userData.email} already exists. Updating...`);
      await prisma.user.update({
        where: { email: userData.email },
        data: {
          passwordHash,
          name: userData.name,
          role: userData.role,
        },
      });
    } else {
      console.log(
        `Creating user: ${userData.email} with role ${userData.role}`
      );
      await prisma.user.create({
        data: {
          email: userData.email,
          passwordHash,
          name: userData.name,
          role: userData.role,
          profile: {
            create: userData.profile,
          },
        },
      });
    }
  }

  // Add some initial measurements for the standard user
  const standardUser = await prisma.user.findUnique({
    where: { email: "usuario@ejemplo.com" },
  });
  if (standardUser) {
    const measurementsCount = await prisma.userMeasurement.count({
      where: { userId: standardUser.id },
    });
    if (measurementsCount === 0) {
      console.log("Adding initial measurements for standard user...");
      await prisma.userMeasurement.create({
        data: {
          userId: standardUser.id,
          age: 25,
          gender: Gender.FEMENINO,
          heightCm: 165,
          weightKg: 62.0,
          goal: UserGoal.MANTENIMIENTO,
          trainingDays: 3,
          neck: 32,
          chest: 88,
          arm: 28,
          waist: 70,
          hips: 95,
          glute: 98,
          leg: 54,
          date: new Date(new Date().setDate(new Date().getDate() - 15)),
        },
      });

      await prisma.userMeasurement.create({
        data: {
          userId: standardUser.id,
          age: 25,
          gender: Gender.FEMENINO,
          heightCm: 165,
          weightKg: 60.5,
          goal: UserGoal.MANTENIMIENTO,
          trainingDays: 3,
          neck: 32,
          chest: 87,
          arm: 27,
          waist: 68,
          hips: 94,
          glute: 97,
          leg: 53,
          date: new Date(),
        },
      });
    }
  }

  // Seed Food Items
  const foodCount = await prisma.foodItem.count();
  if (foodCount === 0) {
    console.log("Seeding food items...");
    const foods = [
      // Proteinas
      {
        name: "Pechuga de Pollo",
        category: "PROTEINA",
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
      },
      {
        name: "Claras de Huevo",
        category: "PROTEINA",
        calories: 52,
        protein: 11,
        carbs: 0.7,
        fat: 0.2,
      },
      {
        name: "Salmón",
        category: "PROTEINA",
        calories: 208,
        protein: 20,
        carbs: 0,
        fat: 13,
      },
      {
        name: "Lomo de Res",
        category: "PROTEINA",
        calories: 250,
        protein: 26,
        carbs: 0,
        fat: 17,
      },
      {
        name: "Atún en Agua",
        category: "PROTEINA",
        calories: 116,
        protein: 26,
        carbs: 0,
        fat: 1,
      },

      // Carbohidratos
      {
        name: "Arroz Integral",
        category: "CARBOHIDRATO",
        calories: 112,
        protein: 2.6,
        carbs: 23,
        fat: 0.9,
      },
      {
        name: "Avena",
        category: "CARBOHIDRATO",
        calories: 389,
        protein: 16.9,
        carbs: 66,
        fat: 6.9,
      },
      {
        name: "Camote",
        category: "CARBOHIDRATO",
        calories: 86,
        protein: 1.6,
        carbs: 20,
        fat: 0.1,
      },
      {
        name: "Quinoa",
        category: "CARBOHIDRATO",
        calories: 120,
        protein: 4.4,
        carbs: 21,
        fat: 1.9,
      },
      {
        name: "Pasta Integral",
        category: "CARBOHIDRATO",
        calories: 124,
        protein: 5.3,
        carbs: 26.5,
        fat: 0.5,
      },

      // Grasas
      {
        name: "Aguacate",
        category: "GRASA",
        calories: 160,
        protein: 2,
        carbs: 8.5,
        fat: 14.7,
      },
      {
        name: "Almendras",
        category: "GRASA",
        calories: 576,
        protein: 21,
        carbs: 22,
        fat: 49,
      },
      {
        name: "Aceite de Oliva",
        category: "GRASA",
        calories: 884,
        protein: 0,
        carbs: 0,
        fat: 100,
      },
      {
        name: "Crema de Cacahuate",
        category: "GRASA",
        calories: 588,
        protein: 25,
        carbs: 20,
        fat: 50,
      },

      // Vegetales
      {
        name: "Espinaca",
        category: "VEGETAL",
        calories: 23,
        protein: 2.9,
        carbs: 3.6,
        fat: 0.4,
      },
      {
        name: "Brócoli",
        category: "VEGETAL",
        calories: 34,
        protein: 2.8,
        carbs: 6.6,
        fat: 0.4,
      },
      {
        name: "Espárragos",
        category: "VEGETAL",
        calories: 20,
        protein: 2.2,
        carbs: 3.9,
        fat: 0.1,
      },
    ];

    for (const food of foods) {
      await prisma.foodItem.create({ data: food });
    }
  }

  // Seed Organizations
  const orgCount = await prisma.organization.count();
  if (orgCount === 0) {
    console.log("Seeding organizations...");
    const orgs = [
      {
        name: "Fitba",
        slug: "fitba",
        primaryColor: "#10B981",
        secondaryColor: "#1F2937",
        logoUrl: "https://fitbafood.vercel.app/logo.png", // Example/Placeholder
        restaurantUrl: "https://fitbafood.vercel.app/",
        nutritionDetails:
          "<ul><li>5 Comidas diarias</li><li>Enfoque en macros balanceados</li></ul>",
      },
      {
        name: "Vitality Health",
        slug: "vitality",
        primaryColor: "#3B82F6",
        secondaryColor: "#1E3A8A",
        logoUrl: null,
        restaurantUrl: null,
        nutritionDetails:
          "<ul><li>Planes personalizados</li><li>Suplementación incluida</li></ul>",
      },
    ];

    for (const org of orgs) {
      await prisma.organization.create({ data: org });
    }
  }

  console.log("Seeding completed successfully.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
