/// Represents a single exercise within a workout plan.
class WorkoutExercise {
  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.notes,
  });

  /// Name of the exercise (e.g., "Bench Press").
  final String name;

  /// Number of sets to perform.
  final int sets;

  /// Number of repetitions per set.
  final int reps;

  /// Target weight to use (optional).
  final double? weight;

  /// Any additional instructions or notes for the exercise.
  final String? notes;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      name: map['name'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight']?.toDouble(),
      notes: map['notes'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkoutExercise &&
        other.name == name &&
        other.sets == sets &&
        other.reps == reps &&
        other.weight == weight &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        sets.hashCode ^
        reps.hashCode ^
        weight.hashCode ^
        notes.hashCode;
  }

  @override
  String toString() {
    return 'WorkoutExercise(name: $name, sets: $sets, reps: $reps, weight: $weight, notes: $notes)';
  }
}

/// Represents a workout plan assigned to a user by a trainer.
class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.trainerId,
    required this.dailyRoutines, // Changed from List to Map
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String trainerId;

  /// Map of day number to list of exercises.
  final Map<int, List<WorkoutExercise>> dailyRoutines;

  final DateTime createdAt;

  WorkoutPlan copyWith({
    String? id,
    String? userId,
    String? trainerId,
    Map<int, List<WorkoutExercise>>? dailyRoutines,
    DateTime? createdAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainerId: trainerId ?? this.trainerId,
      dailyRoutines: dailyRoutines ?? this.dailyRoutines,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    Map<int, List<WorkoutExercise>> routines = {};

    if (map['exercises'] is Map) {
      final Map<String, dynamic> rawRoutines = map['exercises'];
      rawRoutines.forEach((key, value) {
        final day = int.tryParse(key) ?? 1;
        if (value is List) {
          routines[day] = value.map((x) => WorkoutExercise.fromMap(x)).toList();
        }
      });
    } else if (map['exercises'] is List) {
      // Fallback for legacy format or simpler data
      routines[1] = (map['exercises'] as List)
          .map((x) => WorkoutExercise.fromMap(x))
          .toList();
    }

    return WorkoutPlan(
      id: map['id'],
      userId: map['userId'],
      trainerId: map['trainerId'],
      dailyRoutines: routines,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> routinesMap = {};
    dailyRoutines.forEach((key, value) {
      routinesMap[key.toString()] = value.map((x) => x.toMap()).toList();
    });

    return {
      'id': id,
      'userId': userId,
      'trainerId': trainerId,
      'exercises': routinesMap,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
