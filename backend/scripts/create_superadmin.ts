import { PrismaClient, Role } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const email = "superadmin@example.com";
  const password = "supersecretpassword";

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await prisma.user.upsert({
    where: { email },
    update: {
      role: Role.SUPERADMIN,
      organizationId: null,
    },
    create: {
      email,
      name: "Super Admin",
      passwordHash: hashedPassword,
      role: Role.SUPERADMIN,
      organizationId: null,
      isActive: true,
    },
  });

  console.log(`User ${user.email} created/updated with role ${user.role}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
