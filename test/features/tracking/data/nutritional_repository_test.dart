import 'package:flutter_test/flutter_test.dart';
import 'package:imb_health_app/src/features/tracking/data/nutritional_repository.dart';

import 'package:imb_health_app/src/features/tracking/domain/user_measurement.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NutritionalRepository', () {
    late NutritionalRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = NutritionalRepository();
    });

    final testMeasurement = UserMeasurement(
      date: DateTime(2023, 1, 1),
      gender: Gender.male,
      weightKg: 80,
      heightCm: 180,
      age: 25,
      trainingDays: 3,
      goal: UserGoal.maintenance,
      waist: 90,
      neck: 40,
      chest: 100,
      arm: 35,
      hips: 95,
      glute: 100,
      leg: 55,
      bmr: 1805,
      bodyFat: 18.6,
      tdee: 2797.8, // 1805 * 1.55
      targetCalories: 2798,
    );

    test('saveMeasurement should save to latest and history', () async {
      await repository.saveMeasurement(testMeasurement);

      final latest = await repository.getLatestMeasurement();
      expect(latest, isNotNull);
      expect(latest!.weightKg, 80);
      expect(latest.goal, UserGoal.maintenance);

      final history = await repository.getHistory();
      expect(history.length, 1);
      expect(history.first.weightKg, 80);
    });

    test('getLatestMeasurement should return null if no data', () async {
      final latest = await repository.getLatestMeasurement();
      expect(latest, isNull);
    });

    test('getHistory should return empty list if no data', () async {
      final history = await repository.getHistory();
      expect(history, isEmpty);
    });

    test('saveMeasurement should append to history', () async {
      await repository.saveMeasurement(testMeasurement);
      await repository.saveMeasurement(testMeasurement.copyWith(weightKg: 82));

      final history = await repository.getHistory();
      expect(history.length, 2);
      expect(history[0].weightKg, 80);
      expect(history[1].weightKg, 82);

      final latest = await repository.getLatestMeasurement();
      expect(latest!.weightKg, 82);
    });
  });
}
