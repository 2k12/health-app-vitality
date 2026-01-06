class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String bodyPart;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.bodyPart,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      bodyPart: map['bodyPart'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'bodyPart': bodyPart,
    };
  }
}
