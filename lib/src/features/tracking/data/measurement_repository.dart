import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../domain/user_measurement.dart';

class MeasurementRepository {
  final ApiClient _apiClient;

  MeasurementRepository(this._apiClient);

  Future<void> saveMeasurement(UserMeasurement measurement) async {
    try {
      await _apiClient.client.post('/measurements', data: measurement.toMap());
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error al guardar medición');
      }
      rethrow;
    }
  }

  Future<List<UserMeasurement>> getHistory() async {
    try {
      final response = await _apiClient.client.get('/measurements/history');
      final List<dynamic> list = response.data;
      return list.map((e) => UserMeasurement.fromMap(e)).toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error al obtener historial');
      }
      rethrow;
    }
  }

  Future<UserMeasurement?> getLatestMeasurement() async {
    try {
      final history = await getHistory();
      if (history.isNotEmpty) {
        return history.first; // Assumes sorted by latest on backend or here
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserMeasurement>> getHistoryByUserId(String userId) async {
    try {
      final response =
          await _apiClient.client.get('/measurements/user/$userId');
      final List<dynamic> list = response.data;
      return list.map((e) => UserMeasurement.fromMap(e)).toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ??
            'Error al obtener historial del cliente');
      }
      throw e;
    }
  }
}

// Replace the providers from NutritionalRepository with this new implementation

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MeasurementRepository(apiClient);
});

final nutritionalRepositoryProvider = Provider<MeasurementRepository>((ref) {
  return ref.watch(measurementRepositoryProvider);
});

final latestMeasurementProvider = FutureProvider<UserMeasurement?>((ref) async {
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.getLatestMeasurement();
});

final historyProvider = FutureProvider<List<UserMeasurement>>((ref) async {
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.getHistory();
});

final userMeasurementsProvider =
    FutureProvider.family<List<UserMeasurement>, String>((ref, userId) async {
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.getHistoryByUserId(userId);
});
