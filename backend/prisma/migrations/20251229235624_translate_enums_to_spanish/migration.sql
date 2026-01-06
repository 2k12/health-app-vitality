/*
  Warnings:

  - The values [SEDENTARY,MODERATE,ACTIVE] on the enum `ActivityLevel` will be removed. If these variants are still used in the database, this will fail.
  - The values [LOSE_WEIGHT,BUILD_MUSCLE,MAINTENANCE] on the enum `FitnessGoal` will be removed. If these variants are still used in the database, this will fail.
  - The values [MALE,FEMALE,OTHER] on the enum `Gender` will be removed. If these variants are still used in the database, this will fail.
  - The values [USER,ADMIN,TRAINER] on the enum `Role` will be removed. If these variants are still used in the database, this will fail.
  - The values [GAIN,DEFINITION,MAINTENANCE] on the enum `UserGoal` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "ActivityLevel_new" AS ENUM ('SEDENTARIO', 'LIGERO', 'MODERADO', 'ACTIVO', 'MUY_ACTIVO');
ALTER TABLE "UserProfile" ALTER COLUMN "activityLevel" TYPE "ActivityLevel_new" USING ("activityLevel"::text::"ActivityLevel_new");
ALTER TYPE "ActivityLevel" RENAME TO "ActivityLevel_old";
ALTER TYPE "ActivityLevel_new" RENAME TO "ActivityLevel";
DROP TYPE "ActivityLevel_old";
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "FitnessGoal_new" AS ENUM ('PERDER_PESO', 'GANAR_MUSCULO', 'MANTENIMIENTO');
ALTER TABLE "UserProfile" ALTER COLUMN "fitnessGoal" TYPE "FitnessGoal_new" USING ("fitnessGoal"::text::"FitnessGoal_new");
ALTER TYPE "FitnessGoal" RENAME TO "FitnessGoal_old";
ALTER TYPE "FitnessGoal_new" RENAME TO "FitnessGoal";
DROP TYPE "FitnessGoal_old";
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "Gender_new" AS ENUM ('MASCULINO', 'FEMENINO', 'OTRO');
ALTER TABLE "UserProfile" ALTER COLUMN "gender" TYPE "Gender_new" USING ("gender"::text::"Gender_new");
ALTER TABLE "UserMeasurement" ALTER COLUMN "gender" TYPE "Gender_new" USING ("gender"::text::"Gender_new");
ALTER TYPE "Gender" RENAME TO "Gender_old";
ALTER TYPE "Gender_new" RENAME TO "Gender";
DROP TYPE "Gender_old";
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "Role_new" AS ENUM ('USUARIO', 'ADMINISTRADOR', 'ENTRENADOR');
ALTER TABLE "User" ALTER COLUMN "role" DROP DEFAULT;
ALTER TABLE "User" ALTER COLUMN "role" TYPE "Role_new" USING ("role"::text::"Role_new");
ALTER TYPE "Role" RENAME TO "Role_old";
ALTER TYPE "Role_new" RENAME TO "Role";
DROP TYPE "Role_old";
ALTER TABLE "User" ALTER COLUMN "role" SET DEFAULT 'USUARIO';
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "UserGoal_new" AS ENUM ('VOLUMEN', 'DEFINICION', 'MANTENIMIENTO');
ALTER TABLE "UserMeasurement" ALTER COLUMN "goal" TYPE "UserGoal_new" USING ("goal"::text::"UserGoal_new");
ALTER TYPE "UserGoal" RENAME TO "UserGoal_old";
ALTER TYPE "UserGoal_new" RENAME TO "UserGoal";
DROP TYPE "UserGoal_old";
COMMIT;

-- AlterTable
ALTER TABLE "User" ALTER COLUMN "role" SET DEFAULT 'USUARIO';
