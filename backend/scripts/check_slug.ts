import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();
const ORG_ID = "3d869695-7422-460b-8104-c4bcb641b30d";

async function main() {
  const org = await prisma.organization.findUnique({
    where: { id: ORG_ID },
    select: { slug: true, name: true },
  });
  console.log("Organization:", org);
}

main().finally(() => prisma.$disconnect());
