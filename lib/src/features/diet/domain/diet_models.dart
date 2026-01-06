class DietFood {
  final String id;
  final String foodId;
  final String dietMealId;
  final int portionGram;
  final FoodItem food;

  DietFood({
    required this.id,
    required this.foodId,
    required this.dietMealId,
    required this.portionGram,
    required this.food,
  });

  factory DietFood.fromMap(Map<String, dynamic> map) {
    return DietFood(
      id: map['id'] ?? '',
      foodId: map['foodId'] ?? '',
      dietMealId: map['dietMealId'] ?? '',
      portionGram: map['portionGram'] ?? 0,
      food: FoodItem.fromMap(map['food'] ?? {}),
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final String category;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      calories: map['calories'] ?? 0,
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
    );
  }
}

class DietMeal {
  final String id;
  final String dietPlanId;
  final String name;
  final int order;
  final int day;
  final List<DietFood> foods;

  DietMeal({
    required this.id,
    required this.dietPlanId,
    required this.name,
    required this.order,
    this.day = 1,
    required this.foods,
  });

  factory DietMeal.fromMap(Map<String, dynamic> map) {
    return DietMeal(
      id: map['id'] ?? '',
      dietPlanId: map['dietPlanId'] ?? '',
      name: map['name'] ?? '',
      order: map['order'] ?? 0,
      day: map['day'] ?? 1,
      foods: (map['foods'] as List<dynamic>?)
              ?.map((x) => DietFood.fromMap(x))
              .toList() ??
          [],
    );
  }
}
