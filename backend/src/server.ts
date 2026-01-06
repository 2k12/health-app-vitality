import { PrismaClient } from "@prisma/client";
import { connectRedis } from "./utils/redis";
import dotenv from "dotenv";

dotenv.config();

const prisma = new PrismaClient();
const PORT = process.env.PORT || 3000;

async function main() {
  try {
    await prisma.$connect();
    console.log("Connected to Database");
    await connectRedis();

    // Dynamically require app after Redis is connected
    const app = require("./app").default;

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

main();
