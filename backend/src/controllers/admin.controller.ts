import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

// Get all users (Admin view)
export const getAllUsers = async (req: Request, res: Response) => {
  try {
    const userOrgId = (req.user as any).organizationId;

    const users = await (prisma.user as any).findMany({
      where: { organizationId: userOrgId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        isActive: true,
        createdAt: true,
        profile: {
          select: {
            assignedTrainerId: true,
            gender: true,
          },
        },
      },
    });

    res.json(users);
  } catch (error) {
    res.status(500).json({ message: "Error fetching users", error });
  }
};

// Get all trainers (Admin view)
export const getAllTrainers = async (req: Request, res: Response) => {
  try {
    const userOrgId = (req.user as any).organizationId;

    const trainers = await (prisma.user as any).findMany({
      where: {
        role: "ENTRENADOR",
        organizationId: userOrgId,
      },
      select: {
        id: true,
        name: true,
        email: true,
        isActive: true,
      },
    });

    res.json(trainers);
  } catch (error) {
    res.status(500).json({ message: "Error fetching trainers", error });
  }
};

// Assign trainer to user
export const assignTrainer = async (req: Request, res: Response) => {
  try {
    const { userId, trainerId } = req.body;

    // Check if trainer exists and is actually a trainer
    if (trainerId) {
      const trainer = await prisma.user.findUnique({
        where: { id: trainerId },
      });
      if (!trainer || trainer.role !== "ENTRENADOR") {
        return res.status(400).json({ message: "Invalid trainer ID" });
      }
    }

    const updatedProfile = await prisma.userProfile.upsert({
      where: { userId },
      update: { assignedTrainerId: trainerId },
      create: {
        userId,
        assignedTrainerId: trainerId,
        age: 25,
        height: 170,
        weight: 70,
        gender: "OTRO",
        activityLevel: "MODERADO",
        fitnessGoal: "MANTENIMIENTO",
      },
    });

    // If a trainer is assigned, ensure a WorkoutPlan exists or is updated
    if (trainerId) {
      const existingPlan = await prisma.workoutPlan.findFirst({
        where: { userId },
      });

      if (existingPlan) {
        // Update the trainerId on the existing plan
        await prisma.workoutPlan.update({
          where: { id: existingPlan.id },
          data: { trainerId },
        });
      } else {
        // Create a new empty plan
        await prisma.workoutPlan.create({
          data: {
            userId,
            trainerId,
            exercises: {}, // Initialize as empty JSON object for day-based routines
          },
        });
      }
    }

    res.json(updatedProfile);
  } catch (error) {
    res.status(500).json({ message: "Error assigning trainer", error });
  }
};

// Toggle user/trainer active status
export const toggleUserStatus = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body; // Expect boolean

    const updatedUser = await (prisma.user as any).update({
      where: { id },
      data: { isActive },
    });

    res.json(updatedUser);
  } catch (error) {
    res.status(500).json({ message: "Error updating status", error });
  }
};

// Create User with specific role (Admin only)
export const createUser = async (req: Request, res: Response) => {
  try {
    const { email, password, name, role } = req.body;

    if (!email || !password || !name || !role) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ message: "User already exists" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const userOrgId = (req.user as any).organizationId;

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        name,
        role,
        organizationId: userOrgId,
        // Optional: Create empty profile
        profile: {
          create: {
            age: 25,
            height: 170,
            weight: 70,
            gender: "OTRO",
            activityLevel: "MODERADO",
            fitnessGoal: "MANTENIMIENTO",
          },
        },
      },
    });

    res.status(201).json({
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
    });
  } catch (error) {
    console.error("Admin create user error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// Update User (Admin only)
export const updateUser = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, email, role } = req.body;

    // Check if user exists
    const existingUser = await prisma.user.findUnique({ where: { id } });
    if (!existingUser) {
      return res.status(404).json({ message: "User not found" });
    }

    // If email is changing, check for conflicts
    if (email && email !== existingUser.email) {
      const emailConflict = await prisma.user.findUnique({ where: { email } });
      if (emailConflict) {
        return res.status(409).json({ message: "Email already in use" });
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id },
      data: {
        name,
        email,
        role,
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        isActive: true,
      },
    });

    res.json(updatedUser);
  } catch (error) {
    console.error("Error updating user:", error);
    res.status(500).json({ message: "Error updating user" });
  }
};

// Get single user by ID
export const getUserById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const user = await (prisma.user as any).findUnique({
      where: { id },
      include: {
        profile: true,
      },
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      profile: user.profile,
    });
  } catch (error) {
    console.error("Error fetching user:", error);
    res.status(500).json({ message: "Error fetching user" });
  }
};
