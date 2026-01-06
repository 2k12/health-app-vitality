import 'package:flutter_test/flutter_test.dart';
import 'package:imb_health_app/src/features/tracking/application/health_calculator.dart';
import 'package:imb_health_app/src/features/tracking/domain/user_measurement.dart';

void main() {
  group('HealthCalculator Unit Tests', () {
    test('Calculate BMR (Mifflin-St Jeor) - Male', () {
      // Data: Weight 80kg, Height 180cm, Age 25
      // Formula: (10*80) + (6.25*180) - (5*25) + 5
      // = 800 + 1125 - 125 + 5 = 1805
      final result = HealthCalculator.calculateBMR(80, 180, 25, Gender.male);
      expect(result, closeTo(1805, 1.0));
    });

    test('Calculate BMR (Mifflin-St Jeor) - Female', () {
      // Data: Weight 60kg, Height 165cm, Age 30
      // Formula: (10*60) + (6.25*165) - (5*30) - 161
      // = 600 + 1031.25 - 150 - 161 = 1320.25
      final result = HealthCalculator.calculateBMR(60, 165, 30, Gender.female);
      expect(result, closeTo(1320.25, 0.1));
    });

    test('Calculate Body Fat % (US Navy) - Male', () {
      // Data: Waist 90, Neck 40, Height 180
      // Expected approx: ~18-19%
      final result = HealthCalculator.calculateBodyFat(
        gender: Gender.male,
        waist: 90,
        neck: 40,
        height: 180,
      );
      // Based on manual calculation: ~18.57
      expect(result, closeTo(18.6, 0.5));
    });

    test('Calculate Target Calories based on Goal', () {
      const tdee = 2000.0;

      final gain =
          HealthCalculator.calculateTargetCalories(tdee, UserGoal.gain);
      expect(gain, closeTo(2400, 0.1), reason: 'Gain should add 400');

      final definition =
          HealthCalculator.calculateTargetCalories(tdee, UserGoal.definition);
      expect(definition, closeTo(1600, 0.1),
          reason: 'Definition should subtract 400');

      final maintenance =
          HealthCalculator.calculateTargetCalories(tdee, UserGoal.maintenance);
      expect(maintenance, closeTo(2000, 0.1),
          reason: 'Maintenance should be equal to TDEE');
    });
  });
}
