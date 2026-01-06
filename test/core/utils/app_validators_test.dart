import 'package:flutter_test/flutter_test.dart';
import 'package:imb_health_app/src/core/utils/app_validators.dart';

void main() {
  group('AppValidators', () {
    group('isValidEmail', () {
      test('should return error if email is null', () {
        expect(AppValidators.isValidEmail(null), 'Email es requerido');
      });

      test('should return error if email is empty', () {
        expect(AppValidators.isValidEmail(''), 'Email es requerido');
      });

      test('should return error if email format is invalid', () {
        expect(AppValidators.isValidEmail('invalid-email'),
            'Ingresa un email válido');
        expect(AppValidators.isValidEmail('test@'), 'Ingresa un email válido');
        expect(
            AppValidators.isValidEmail('@test.com'), 'Ingresa un email válido');
      });

      test('should return null if email is valid', () {
        expect(AppValidators.isValidEmail('test@example.com'), null);
        expect(AppValidators.isValidEmail('user.name@domain.co.uk'), null);
      });
    });

    group('isValidPassword', () {
      test('should return error if password is null', () {
        expect(AppValidators.isValidPassword(null), 'Contraseña requerida');
      });

      test('should return error if password is empty', () {
        expect(AppValidators.isValidPassword(''), 'Contraseña requerida');
      });

      test('should return error if password is too short', () {
        expect(AppValidators.isValidPassword('12345'), 'Mínimo 6 caracteres');
      });

      test('should return null if password is valid', () {
        expect(AppValidators.isValidPassword('123456'), null);
        expect(AppValidators.isValidPassword('password123'), null);
      });
    });

    group('isRequired', () {
      test('should return error if value is null', () {
        expect(AppValidators.isRequired(null), 'Este campo es requerido');
      });

      test('should return error if value is empty', () {
        expect(AppValidators.isRequired(''), 'Este campo es requerido');
      });

      test('should return null if value is provided', () {
        expect(AppValidators.isRequired('some value'), null);
      });
    });
  });
}
