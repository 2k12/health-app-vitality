import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || "fallback_secret";

export const register = async (req: Request, res: Response) => {
  try {
    const {
      email,
      password,
      name,
      height,
      gender,
      age,
      weight,
      activityLevel,
      fitnessGoal,
    } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ message: "User already exists" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        name,
        profile: {
          create: {
            height: height || 170, /// Default
            gender: gender || "OTRO",
            age: age || 25,
            weight: weight || 70,
            activityLevel: activityLevel || "MODERADO",
            fitnessGoal: fitnessGoal || "MANTENIMIENTO",
          },
        },
      },
      include: {
        profile: true,
      },
    });

    const token = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role,
        organizationId: user.organizationId,
      },
      JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );

    res.status(201).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        acceptedTerms: user.acceptedTerms,
      },
    });
  } catch (error) {
    console.error("Register error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    let { email, password } = req.body;

    // Sanitize input to prevent Postgres UTF8 0x00 error
    if (typeof email === "string") {
      email = email.replace(/\0/g, "").trim();
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const validPassword = await bcrypt.compare(password, user.passwordHash);
    if (!validPassword) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    if (!user.isActive) {
      return res.status(403).json({
        message:
          "Tu cuenta ha sido desactivada. Por favor, contacta al administrador.",
      });
    }

    // Organization Context Validation
    const { orgSlug } = req.body;
    if (orgSlug && user.role !== "SUPERADMIN") {
      const organization = await prisma.organization.findUnique({
        where: { slug: orgSlug },
      });

      if (organization) {
        // If user has an assigned organization, it MUST match
        if (user.organizationId && user.organizationId !== organization.id) {
          return res.status(403).json({
            message: `No tienes permiso para acceder a la organización ${organization.name}.`,
          });
        }

        // Optional: If user has NO organizationId, maybe we allow them or block them?
        // Usually, a user must belong to an org.
        // If strict mode:
        if (!user.organizationId) {
          return res.status(403).json({
            message: "Tu cuenta no está asociada a ninguna organización.",
          });
        }
      }
    }

    const token = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role,
        organizationId: user.organizationId,
      },
      JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        acceptedTerms: user.acceptedTerms,
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const acceptTerms = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;

    const user = await prisma.user.update({
      where: { id: userId },
      data: { acceptedTerms: true },
    });

    res.json({
      message: "Terms accepted successfully",
      acceptedTerms: user.acceptedTerms,
    });
  } catch (error) {
    console.error("Accept terms error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getMe = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true },
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (!user.isActive) {
      return res.status(403).json({
        message: "Tu cuenta ha sido desactivada.",
      });
    }

    res.json({
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      isActive: user.isActive,
      acceptedTerms: user.acceptedTerms,
      profile: user.profile,
    });
  } catch (error) {
    res.status(500).json({ message: "Internal server error" });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;
    const {
      name,
      email,
      password,
      age,
      gender,
      height,
      weight,
      activityLevel,
      fitnessGoal,
    } = req.body;

    const dataToUpdate: any = {};
    if (name) dataToUpdate.name = name;
    if (email) dataToUpdate.email = email;
    if (password) {
      dataToUpdate.passwordHash = await bcrypt.hash(password, 10);
    }

    // Profile update data
    const profileUpdate: any = {};
    if (age !== undefined) profileUpdate.age = Number(age);
    if (gender) profileUpdate.gender = gender;
    if (height !== undefined) profileUpdate.height = Number(height);
    if (weight !== undefined) profileUpdate.weight = Number(weight);
    if (activityLevel) profileUpdate.activityLevel = activityLevel;
    if (fitnessGoal) profileUpdate.fitnessGoal = fitnessGoal;

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...dataToUpdate,
        profile: {
          upsert: {
            create: {
              age: Number(age) || 25,
              gender: gender || "OTRO",
              height: Number(height) || 170,
              weight: Number(weight) || 70,
              activityLevel: activityLevel || "MODERADO",
              fitnessGoal: fitnessGoal || "MANTENIMIENTO",
            },
            update: profileUpdate,
          },
        },
      },
      include: {
        profile: true,
      },
    });

    // Handle Training Days update -> Modify Workout Plan
    const trainingDays = req.body.trainingDays
      ? Number(req.body.trainingDays)
      : null;
    if (trainingDays !== null && trainingDays > 0) {
      const plan = await prisma.workoutPlan.findFirst({
        where: { userId },
        orderBy: { createdAt: "desc" },
      });

      if (plan && plan.exercises) {
        let exercises: any = plan.exercises;

        // Normalize to Array
        if (typeof exercises === "string") {
          try {
            exercises = JSON.parse(exercises);
          } catch {
            exercises = [];
          }
        }
        if (!Array.isArray(exercises) && typeof exercises === "object") {
          // Convert legacy object to array
          const keys = Object.keys(exercises)
            .map(Number)
            .sort((a, b) => a - b);
          exercises = keys.map((k) => ({
            day: k,
            exercises: exercises[String(k)] || [],
          }));
        }
        if (!Array.isArray(exercises)) exercises = [];

        // Slice to new length
        if (exercises.length > trainingDays) {
          exercises = exercises.slice(0, trainingDays);

          await prisma.workoutPlan.update({
            where: { id: plan.id },
            data: { exercises },
          });
        }
      }
    }

    // Notify Trainer if profile updated (specifically for training days or generic)
    // We check if the user has an assigned trainer
    const userProfile = await prisma.userProfile.findUnique({
      where: { userId },
    });
    if (userProfile && userProfile.assignedTrainerId) {
      // Create Notification for Trainer
      const isTrainingDaysChange = trainingDays !== null;

      if (isTrainingDaysChange) {
        await prisma.notification.create({
          data: {
            userId: userProfile.assignedTrainerId,
            title: "Actualización de Cliente",
            message: `El usuario ${user.name} ha actualizado sus días de entrenamiento a ${trainingDays} días. Por favor revisa su plan.`,
            type: "CLIENT_UPDATE",
          },
        });
      }
    }

    res.json({
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      isActive: user.isActive,
      acceptedTerms: user.acceptedTerms,
      profile: user.profile,
    });
  } catch (error) {
    console.error("Update profile error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
