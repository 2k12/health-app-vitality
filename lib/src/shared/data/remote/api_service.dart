import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // TODO: Replace with your actual backend URL. Use 10.0.2.2 for Android Emulator.
  static const String _baseUrl = 'http://localhost:3000/api';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle 401 Unauthorized globally if needed (e.g. logout)
        return handler.next(e);
      },
    ));
  }

  // Auth Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
        // Default values for now, can be expanded
        'height': 175,
        'gender': 'OTRO'
      });
      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Measurement Methods
  Future<void> saveMeasurement(Map<String, dynamic> measurementData) async {
    try {
      await _dio.post('/measurements', data: measurementData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getHistory() async {
    try {
      final response = await _dio.get('/measurements/history');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
