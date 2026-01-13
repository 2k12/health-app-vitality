import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const slug = "fitba";
  const name = "Fitba";
  const primaryColor = "#10B981"; // Emerald Green
  const secondaryColor = "#1F2937"; // Gray 800

  // Upsert Organization
  const org = await prisma.organization.upsert({
    where: { slug },
    update: {
      name,
      primaryColor,
      secondaryColor,
      restaurantUrl: "https://fitbafood.vercel.app/",
    },
    create: {
      slug,
      name,
      primaryColor,
      secondaryColor,
      logoUrl: null, // Placeholder or user can update later
      restaurantUrl: "https://fitbafood.vercel.app/",
    },
  });

  console.log(`Organization '${org.name}' (slug: ${org.slug}) ensured.`);

  // Optional: Link existing users without org to this org
  // This helps migration
  const usersWithoutOrg = await prisma.user.updateMany({
    where: { organizationId: null },
    data: { organizationId: org.id },
  });

  console.log(`Linked ${usersWithoutOrg.count} user(s) to ${org.name}.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
