import 'dart:math';
import '../domain/user_measurement.dart';

class HealthCalculator {
  /// Calculate BMR using Mifflin-St Jeor Equation
  static double calculateBMR(
      double weightKg, double heightCm, int age, Gender gender) {
    // Men: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) + 5
    // Women: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) - 161

    double base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);

    if (gender == Gender.male) {
      return base + 5;
    } else {
      return base - 161;
    }
  }

  /// Calculate Body Fat % using US Navy Method
  static double calculateBodyFat({
    required Gender gender,
    required double waist,
    required double neck,
    required double height,
    double? hips, // Required for women only
  }) {
    // Measurements in cm, height in cm
    // Log10 is not standard in Dart math, use log(x) / ln(10)
    double log10(num x) => log(x) / ln10;

    if (gender == Gender.male) {
      // Men: 495 / (1.0324 - 0.19077(log10(waist - neck)) + 0.15456(log10(height))) - 450
      // waist and neck in cm

      // Ensure positive log arguments
      if (waist - neck <= 0) return 0.0;

      return 495 /
              (1.0324 -
                  0.19077 * log10(waist - neck) +
                  0.15456 * log10(height)) -
          450;
    } else {
      // Women: 495 / (1.29579 - 0.35004(log10(waist + hip - neck)) + 0.22100(log10(height))) - 450
      double hipValue =
          hips ?? waist; // Fallback if hip not provided (should be provided)

      if (waist + hipValue - neck <= 0) return 0.0;

      return 495 /
              (1.29579 -
                  0.35004 * log10(waist + hipValue - neck) +
                  0.22100 * log10(height)) -
          450;
    }
  }

  /// Calculate TDEE based on activity level
  static double calculateTDEE(double bmr, int trainingDays) {
    // Activity Multipliers:
    // Sedentary (0-1 days): 1.2
    // Lightly active (1-3 days): 1.375
    // Moderately active (3-5 days): 1.55
    // Very active (6-7 days): 1.725

    double multiplier;
    if (trainingDays <= 1) {
      multiplier = 1.2;
    } else if (trainingDays <= 3) {
      multiplier = 1.375;
    } else if (trainingDays <= 5) {
      multiplier = 1.55;
    } else {
      multiplier = 1.725;
    }

    return bmr * multiplier;
  }

  /// Calculate Target Calories based on Goal
  static double calculateTargetCalories(double tdee, UserGoal goal) {
    switch (goal) {
      case UserGoal.gain:
        return tdee + 400; // Surplus
      case UserGoal.definition:
        return tdee - 400; // Deficit
      case UserGoal.maintenance:
        return tdee;
    }
  }

  /// Helper to calculate everything and return a new UserMeasurement object with computed values
  static UserMeasurement computeAll(UserMeasurement input) {
    final bmr =
        calculateBMR(input.weightKg, input.heightCm, input.age, input.gender);
    final bodyFat = calculateBodyFat(
      gender: input.gender,
      waist: input.waist,
      neck: input.neck,
      height: input.heightCm,
      hips: input.hips,
    );
    final tdee = calculateTDEE(bmr, input.trainingDays);
    final targetCals = calculateTargetCalories(tdee, input.goal);

    return input.copyWith(
      bmr: double.parse(bmr.toStringAsFixed(1)),
      bodyFat: double.parse(bodyFat.toStringAsFixed(1)),
      tdee: double.parse(tdee.toStringAsFixed(1)),
      targetCalories: double.parse(targetCals.toStringAsFixed(0)),
    );
  }
}
