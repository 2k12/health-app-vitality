import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import { rateLimit } from "express-rate-limit";
import { RedisStore } from "rate-limit-redis";
import redisClient from "./utils/redis";
import authRoutes from "./routes/auth.routes";
import measurementRoutes from "./routes/measurement.routes";
import dietRoutes from "./routes/diet.routes";
import workoutRoutes from "./routes/workout.routes";
import profileRoutes from "./routes/profile.routes";
import trainerRoutes from "./routes/trainer.routes";
import exerciseRoutes from "./routes/exercise.routes";

const app = express();

// Middleware
app.use(cors());
app.use(helmet());
app.use(morgan("dev"));
app.use(express.json());

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5000, // Limit each IP to 5000 requests per `window` (development friendly)
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  store: new RedisStore({
    sendCommand: (...args: string[]) => {
      // console.log(`[Redis] RateLimit Command: ${args[0]}`);
      return redisClient.sendCommand(args);
    },
  }),
  handler: (req, res, next, options) => {
    console.log(`[RateLimit] Limit reached for IP: ${req.ip}`);
    res.status(options.statusCode).send(options.message);
  },
});

app.use(limiter);

// Routes

import adminRoutes from "./routes/admin.routes";
import foodRoutes from "./routes/food.routes";

// ... existing imports

import notificationRoutes from "./routes/notification.routes";
import organizationRoutes from "./routes/organization.routes";

app.use("/api/auth", authRoutes);
app.use("/api/measurements", measurementRoutes);
app.use("/api/diet", dietRoutes);
app.use("/api/workout", workoutRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/foods", foodRoutes);
app.use("/api/trainer", trainerRoutes);
app.use("/api/exercises", exerciseRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/organization", organizationRoutes);

// Health check
app.get("/", (req, res) => {
  res.send("FitBaCenter API is running");
});

export default app;
