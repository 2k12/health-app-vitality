import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../domain/app_user.dart';

class AuthRepository extends StateNotifier<AppUser?> {
  final ApiClient _apiClient;
  final Ref _ref;

  AuthRepository(this._apiClient, this._ref) : super(null);

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _apiClient.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      final userMap = response.data['user'];

      // Save token
      final storage = _ref.read(secureStorageProvider);
      await storage.write(key: 'auth_token', value: token);

      // Update state
      state = AppUser.fromMap(userMap);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error al iniciar sesión');
      }
      throw Exception('Error inesperado: $e');
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      final response = await _apiClient.client.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
        // Default values for required fields or add params to signUp
        'height': 170,
        'gender': 'OTRO'
      });

      final token = response.data['token'];
      final userMap = response.data['user'];

      final storage = _ref.read(secureStorageProvider);
      await storage.write(key: 'auth_token', value: token);

      state = AppUser.fromMap(userMap);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Error al registrarse');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    final storage = _ref.read(secureStorageProvider);
    await storage.delete(key: 'auth_token');
    state = null;
  }

  Future<void> refreshUser() async {
    try {
      final response = await _apiClient.client.get('/auth/me');
      state = AppUser.fromMap(response.data);
    } catch (e) {
      // If refresh fails (e.g., token expired or deactivated), sign out
      if (e is DioException &&
          (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
        await signOut();
      }
    }
  }
}

final authRepositoryProvider =
    StateNotifierProvider<AuthRepository, AppUser?>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient, ref);
});
