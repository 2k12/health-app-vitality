import 'diet_models.dart';

/// Represents a daily diet plan assigned to a user.
class DietPlan {
  const DietPlan({
    required this.id,
    required this.userId,
    required this.dailyCalories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    this.meals = const [],
  });

  factory DietPlan.fromMap(Map<String, dynamic> map) {
    return DietPlan(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      dailyCalories: map['dailyCalories'] ?? 0,
      proteinGrams: map['proteinGrams'] ?? 0,
      carbohydrateGrams: map['carbohydrateGrams'] ?? 0,
      fatGrams: map['fatGrams'] ?? 0,
      meals: (map['meals'] as List<dynamic>?)
              ?.map((x) => DietMeal.fromMap(x))
              .toList() ??
          [],
    );
  }

  /// Unique identifier for this diet plan.
  final String id;

  /// ID of the user this plan is assigned to.
  final String userId;

  /// Target daily caloric intake.
  final int dailyCalories;

  /// Target daily protein intake in grams.
  final int proteinGrams;

  /// Target daily carbohydrate intake in grams.
  final int carbohydrateGrams;

  /// Target daily fat intake in grams.
  final int fatGrams;

  /// List of meals in the plan
  final List<DietMeal> meals;

  DietPlan copyWith({
    String? id,
    String? userId,
    int? dailyCalories,
    int? proteinGrams,
    int? carbohydrateGrams,
    int? fatGrams,
    List<DietMeal>? meals,
  }) {
    return DietPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbohydrateGrams: carbohydrateGrams ?? this.carbohydrateGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      meals: meals ?? this.meals,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DietPlan &&
        other.id == id &&
        other.userId == userId &&
        other.dailyCalories == dailyCalories &&
        other.proteinGrams == proteinGrams &&
        other.carbohydrateGrams == carbohydrateGrams &&
        other.fatGrams == fatGrams;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        dailyCalories.hashCode ^
        proteinGrams.hashCode ^
        carbohydrateGrams.hashCode ^
        fatGrams.hashCode;
  }

  @override
  String toString() {
    return 'DietPlan(id: $id, userId: $userId, dailyCalories: $dailyCalories, proteinGrams: $proteinGrams, carbohydrateGrams: $carbohydrateGrams, fatGrams: $fatGrams)';
  }
}
