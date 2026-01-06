/// Gender of the user.
enum Gender {
  male,
  female,
}

/// Physical activity level of the user.
enum ActivityLevel {
  sedentary,
  moderate,
  active,
}

/// Primary fitness goal of the user.
enum FitnessGoal {
  loseWeight,
  buildMuscle,
  maintenance,
}

/// Detailed profile of the user containing physical attributes and goals.
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.fitnessGoal,
    this.assignedTrainerId,
  });

  /// The ID of the AppUser this profile belongs to.
  final String userId;

  /// Age of the user in years.
  final int age;

  /// Gender of the user.
  final Gender gender;

  /// Height of the user in centimeters (or meters, logic to be defined).
  /// Assuming centimeters for now as it's common (e.g. 175.0).
  final double height;

  /// Weight of the user in kilograms.
  final double weight;

  /// Activity level of the user.
  final ActivityLevel activityLevel;

  /// Fitness goal of the user.
  final FitnessGoal fitnessGoal;

  /// ID of the trainer assigned to this user, if any.
  final String? assignedTrainerId;

  UserProfile copyWith({
    String? userId,
    int? age,
    Gender? gender,
    double? height,
    double? weight,
    ActivityLevel? activityLevel,
    FitnessGoal? fitnessGoal,
    String? assignedTrainerId,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': _genderToPrisma(gender),
      'height': height,
      'weight': weight,
      'activityLevel': _activityLevelToPrisma(activityLevel),
      'fitnessGoal': _fitnessGoalToPrisma(fitnessGoal),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      age: map['age'] ?? 0,
      gender: _parseGender(map['gender']),
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      activityLevel: _parseActivityLevel(map['activityLevel']),
      fitnessGoal: _parseFitnessGoal(map['fitnessGoal']),
      assignedTrainerId: map['assignedTrainerId'],
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

  static ActivityLevel _parseActivityLevel(String? val) {
    if (val == 'ACTIVO') return ActivityLevel.active;
    if (val == 'SEDENTARIO') return ActivityLevel.sedentary;
    return ActivityLevel.moderate;
  }

  static String _activityLevelToPrisma(ActivityLevel val) {
    switch (val) {
      case ActivityLevel.active:
        return 'ACTIVO';
      case ActivityLevel.sedentary:
        return 'SEDENTARIO';
      case ActivityLevel.moderate:
        return 'MODERADO';
    }
  }

  static FitnessGoal _parseFitnessGoal(String? val) {
    if (val == 'PERDER_PESO') return FitnessGoal.loseWeight;
    if (val == 'GANAR_MUSCULO') return FitnessGoal.buildMuscle;
    return FitnessGoal.maintenance;
  }

  String _fitnessGoalToPrisma(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'PERDER_PESO';
      case FitnessGoal.buildMuscle:
        return 'GANAR_MUSCULO';
      case FitnessGoal.maintenance:
        return 'MANTENIMIENTO';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.userId == userId &&
        other.age == age &&
        other.gender == gender &&
        other.height == height &&
        other.weight == weight &&
        other.activityLevel == activityLevel &&
        other.fitnessGoal == fitnessGoal &&
        other.assignedTrainerId == assignedTrainerId;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        age.hashCode ^
        gender.hashCode ^
        height.hashCode ^
        weight.hashCode ^
        activityLevel.hashCode ^
        fitnessGoal.hashCode ^
        assignedTrainerId.hashCode;
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, age: $age, gender: $gender, height: $height, weight: $weight, activityLevel: $activityLevel, fitnessGoal: $fitnessGoal, assignedTrainerId: $assignedTrainerId)';
  }
}
