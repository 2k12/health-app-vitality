import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import { getCache, setCache, deleteCache } from "../utils/redis";

const prisma = new PrismaClient();

// Get all foods
export const getAllFoods = async (req: Request, res: Response) => {
  try {
    const cacheKey = "foods:all";
    const cachedFoods = await getCache(cacheKey);
    if (cachedFoods) {
      return res.json(cachedFoods);
    }

    const foods = await prisma.foodItem.findMany();
    await setCache(cacheKey, foods, 3600); // Cache for 1 hour
    res.json(foods);
  } catch (error) {
    res.status(500).json({ message: "Error fetching foods", error });
  }
};

// Create food
export const createFood = async (req: Request, res: Response) => {
  try {
    const { name, category, calories, protein, carbs, fat } = req.body;
    const food = await prisma.foodItem.create({
      data: { name, category, calories, protein, carbs, fat },
    });
    await deleteCache("foods:all");
    res.json(food);
  } catch (error) {
    res.status(500).json({ message: "Error creating food", error });
  }
};

// Update food
export const updateFood = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, category, calories, protein, carbs, fat } = req.body;
    const food = await prisma.foodItem.update({
      where: { id },
      data: { name, category, calories, protein, carbs, fat },
    });
    await deleteCache("foods:all");
    res.json(food);
  } catch (error) {
    res.status(500).json({ message: "Error updating food", error });
  }
};

// Delete food
export const deleteFood = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.foodItem.delete({ where: { id } });
    await deleteCache("foods:all");
    res.json({ message: "Food deleted" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting food", error });
  }
};
