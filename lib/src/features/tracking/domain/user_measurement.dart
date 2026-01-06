enum UserGoal {
  gain,
  definition,
  maintenance,
}

enum Gender {
  male,
  female,
}

class UserMeasurement {
  final DateTime date;

  // Bio
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;

  // Goal & Activity
  final UserGoal goal;
  final int trainingDays; // 0-7

  // Measurements (cm)
  final double neck;
  final double chest;
  final double arm;
  final double waist;
  final double hips;
  final double glute;
  final double leg;

  // Computed Results
  final double? bodyFat;
  final double? bmr;
  final double? tdee;
  final double? targetCalories;

  UserMeasurement({
    required this.date,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.trainingDays,
    required this.neck,
    required this.chest,
    required this.arm,
    required this.waist,
    required this.hips,
    required this.glute,
    required this.leg,
    this.bodyFat,
    this.bmr,
    this.tdee,
    this.targetCalories,
  });

  UserMeasurement copyWith({
    DateTime? date,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    UserGoal? goal,
    int? trainingDays,
    double? neck,
    double? chest,
    double? arm,
    double? waist,
    double? hips,
    double? glute,
    double? leg,
    double? bodyFat,
    double? bmr,
    double? tdee,
    double? targetCalories,
  }) {
    return UserMeasurement(
      date: date ?? this.date,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      trainingDays: trainingDays ?? this.trainingDays,
      neck: neck ?? this.neck,
      chest: chest ?? this.chest,
      arm: arm ?? this.arm,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      glute: glute ?? this.glute,
      leg: leg ?? this.leg,
      bodyFat: bodyFat ?? this.bodyFat,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      targetCalories: targetCalories ?? this.targetCalories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'age': age,
      'gender': _genderToPrisma(gender),
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goal': _goalToPrisma(goal),
      'trainingDays': trainingDays,
      'neck': neck,
      'chest': chest,
      'arm': arm,
      'waist': waist,
      'hips': hips,
      'glute': glute,
      'leg': leg,
      'bodyFat': bodyFat,
      'bmr': bmr,
      'tdee': tdee,
      'targetCalories': targetCalories,
    };
  }

  factory UserMeasurement.fromMap(Map<String, dynamic> map) {
    return UserMeasurement(
      date: DateTime.parse(map['date']),
      age: map['age'],
      gender: _parseGender(map['gender']),
      heightCm: (map['heightCm'] as num).toDouble(),
      weightKg: (map['weightKg'] as num).toDouble(),
      goal: _parseGoal(map['goal']),
      trainingDays: map['trainingDays'],
      neck: (map['neck'] as num).toDouble(),
      chest: (map['chest'] as num).toDouble(),
      arm: (map['arm'] as num).toDouble(),
      waist: (map['waist'] as num).toDouble(),
      hips: (map['hips'] as num).toDouble(),
      glute: (map['glute'] as num).toDouble(),
      leg: (map['leg'] as num).toDouble(),
      bodyFat:
          map['bodyFat'] != null ? (map['bodyFat'] as num).toDouble() : null,
      bmr: map['bmr'] != null ? (map['bmr'] as num).toDouble() : null,
      tdee: map['tdee'] != null ? (map['tdee'] as num).toDouble() : null,
      targetCalories: map['targetCalories'] != null
          ? (map['targetCalories'] as num).toDouble()
          : null,
    );
  }

  static Gender _parseGender(String? val) {
    if (val == 'FEMENINO') return Gender.female;
    return Gender.male;
  }

  static String _genderToPrisma(Gender val) {
    switch (val) {
      case Gender.female:
        return 'FEMENINO';
      case Gender.male:
        return 'MASCULINO';
    }
  }

  static UserGoal _parseGoal(String? val) {
    if (val == 'VOLUMEN') return UserGoal.gain;
    if (val == 'DEFINICION') return UserGoal.definition;
    return UserGoal.maintenance;
  }

  static String _goalToPrisma(UserGoal val) {
    switch (val) {
      case UserGoal.gain:
        return 'VOLUMEN';
      case UserGoal.definition:
        return 'DEFINICION';
      case UserGoal.maintenance:
        return 'MANTENIMIENTO';
    }
  }
}
