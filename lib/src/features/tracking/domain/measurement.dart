/// Represents a measurement record for a user.
class Measurement {
  const Measurement({
    required this.id,
    required this.userId,
    required this.date,
    required this.weight,
    required this.chest,
    required this.waist,
    required this.bodyFatPercentage,
  });

  /// Unique identifier for the measurement entry.
  final String id;

  /// The ID of the user this measurement belongs to.
  final String userId;

  /// The date when the measurement was taken.
  final DateTime date;

  /// Weight in kilograms (or preferred unit).
  final double weight;

  /// Chest circumference in centimeters.
  final double chest;

  /// Waist circumference in centimeters (or preferred unit).
  final double waist;

  /// Body fat percentage (0-100).
  final double bodyFatPercentage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Measurement &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        other.weight == weight &&
        other.chest == chest &&
        other.waist == waist &&
        other.bodyFatPercentage == bodyFatPercentage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        date.hashCode ^
        weight.hashCode ^
        chest.hashCode ^
        waist.hashCode ^
        bodyFatPercentage.hashCode;
  }

  @override
  String toString() {
    return 'Measurement(id: $id, userId: $userId, date: $date, weight: $weight, chest: $chest, waist: $waist, bodyFatPercentage: $bodyFatPercentage)';
  }
}
