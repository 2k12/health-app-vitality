import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_profile.dart';
import '../domain/diet_plan.dart';

class DietGeneratorService {
  DietPlan generateDietPlan(UserProfile profile) {
    // 1. Calculate BMR (Harris-Benedict)
    double bmr;
    if (profile.gender == Gender.male) {
      bmr = 88.362 +
          (13.397 * profile.weight) +
          (4.799 * profile.height) -
          (5.677 * profile.age);
    } else {
      bmr = 447.593 +
          (9.247 * profile.weight) +
          (3.098 * profile.height) -
          (4.330 * profile.age);
    }

    // 2. Activity Multiplier
    double multiplier;
    switch (profile.activityLevel) {
      case ActivityLevel.sedentary:
        multiplier = 1.2;
        break;
      case ActivityLevel.moderate:
        multiplier = 1.55;
        break;
      case ActivityLevel.active:
        multiplier = 1.725;
        break;
    }
    double tdee = bmr * multiplier;

    // 3. Goal Adjustment
    int calorieAdjustment = 0;
    switch (profile.fitnessGoal) {
      case FitnessGoal.loseWeight:
        calorieAdjustment = -500;
        break;
      case FitnessGoal.buildMuscle:
        calorieAdjustment = 500;
        break;
      case FitnessGoal.maintenance:
        calorieAdjustment = 0;
        break;
    }

    int targetCalories = (tdee + calorieAdjustment).round();
    // Ensure safety (min 1200 kcal?)
    if (targetCalories < 1200) targetCalories = 1200;

    // 4. Macros
    // Protein: 2g per kg
    int proteinGrams = (profile.weight * 2).round();
    int proteinCals = proteinGrams * 4;

    // Remaining calories
    // int remainingCals = targetCalories - proteinCals;

    // Fat: Let's aim for ~25% of total calories or 0.8g/kg.
    // Simple approach: 30% of total calories to fat, rest to carbs.
    int fatCals = (targetCalories * 0.30).round();
    int fatGrams = (fatCals / 9).round();

    int carbsCals = targetCalories - proteinCals - fatCals;
    int carbsGrams = (carbsCals / 4).round();

    return DietPlan(
      id: 'generated-${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.userId,
      dailyCalories: targetCalories,
      proteinGrams: proteinGrams,
      carbohydrateGrams: carbsGrams > 0 ? carbsGrams : 0,
      fatGrams: fatGrams,
    );
  }
}

final dietGeneratorProvider = Provider<DietGeneratorService>((ref) {
  return DietGeneratorService();
});
