import { createClient } from "redis";

const redisClient = createClient({
  url: process.env.REDIS_URL || "redis://localhost:6379",
});

redisClient.on("error", (err) => console.error("Redis Client Error", err));

export const connectRedis = async () => {
  if (!redisClient.isOpen) {
    await redisClient.connect();
    console.log("Connected to Redis");
  }
};

export const getCache = async (key: string) => {
  try {
    const data = await redisClient.get(key);
    if (data) {
      console.log(`[Redis] Cache HIT for key: ${key}`);
      return JSON.parse(data);
    }
    console.log(`[Redis] Cache MISS for key: ${key}`);
    return null;
  } catch (error) {
    console.error(`Error getting cache for key ${key}:`, error);
    return null;
  }
};

export const setCache = async (
  key: string,
  value: any,
  ttlSeconds: number = 3600
) => {
  try {
    console.log(`[Redis] Setting cache for key: ${key} (TTL: ${ttlSeconds}s)`);
    await redisClient.set(key, JSON.stringify(value), {
      EX: ttlSeconds,
    });
  } catch (error) {
    console.error(`Error setting cache for key ${key}:`, error);
  }
};

export const deleteCache = async (key: string) => {
  try {
    await redisClient.del(key);
  } catch (error) {
    console.error(`Error deleting cache for key ${key}:`, error);
  }
};

export const deleteCacheByPattern = async (pattern: string) => {
  try {
    const keys = await redisClient.keys(pattern);
    if (keys.length > 0) {
      await redisClient.del(keys);
    }
  } catch (error) {
    console.error(`Error deleting cache by pattern ${pattern}:`, error);
  }
};

export default redisClient;
