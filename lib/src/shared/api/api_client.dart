import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Constante para la URL base - Ajustar según entorno (android emulator: 10.0.2.2, iOS/Web: localhost)
// Usamos localhost para web/escritorio por defecto en desarrollo
// const String kBaseUrl = 'http://localhost:3000/api';
const String kBaseUrl = 'http://10.0.2.2:3000/api';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage) : _dio = Dio(BaseOptions(baseUrl: kBaseUrl)) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors like 401 Unauthorized
        if (e.response?.statusCode == 401) {
          // Could trigger logout logic here using a stream or callback
        }
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});
