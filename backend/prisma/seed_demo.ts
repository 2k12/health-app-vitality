import { PrismaClient, Role } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const slug = "bluefit";
  const name = "BlueFit Gym";
  const primaryColor = "#3B82F6"; // Blue-500
  const secondaryColor = "#1E3A8A"; // Blue-900

  // 1. Create Organization
  const org = await prisma.organization.upsert({
    where: { slug },
    update: {
      name,
      primaryColor,
      secondaryColor,
      restaurantUrl: null,
    },
    create: {
      slug,
      name,
      primaryColor,
      secondaryColor,
      logoUrl: null,
      restaurantUrl: null,
    },
  });

  console.log(`Organization '${org.name}' created/updated.`);

  // 2. Create Users
  const passwordHash = await bcrypt.hash("123456", 10);

  const users = [
    { email: "admin@blue.com", role: Role.ADMINISTRADOR, name: "Admin Blue" },
    { email: "trainer@blue.com", role: Role.ENTRENADOR, name: "Trainer Blue" },
    { email: "user@blue.com", role: Role.USUARIO, name: "User Blue" },
  ];

  for (const u of users) {
    const user = await prisma.user.upsert({
      where: { email: u.email },
      update: {
        organizationId: org.id,
        role: u.role,
      },
      create: {
        email: u.email,
        name: u.name,
        passwordHash,
        role: u.role,
        organizationId: org.id,
        isActive: true,
      },
    });

    // Create Profile if needed
    if (u.role === Role.USUARIO) {
      await prisma.userProfile.upsert({
        where: { userId: user.id },
        update: {},
        create: {
          userId: user.id,
          age: 25,
          gender: "MASCULINO",
          height: 175,
          weight: 75,
          activityLevel: "MODERADO",
          fitnessGoal: "MANTENIMIENTO",
        },
      });
    }

    console.log(`User ${u.email} (${u.role}) created for ${org.name}.`);
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
