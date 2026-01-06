import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../domain/diet_plan.dart';

class DietRepository {
  final ApiClient _apiClient;

  DietRepository(this._apiClient);

  Future<List<DietPlan>> getDietPlans() async {
    try {
      final response = await _apiClient.client.get('/diet');

      if (response.data == null) {
        return [];
      }

      // Backend returns a single object (latest plan) or null.
      // We wrap it in a list to satisfy the return type.
      if (response.data is Map<String, dynamic>) {
        return [DietPlan.fromMap(response.data)];
      }

      // If it IS a list (legacy or future support)
      if (response.data is List) {
        final List<dynamic> list = response.data;
        return list.map((e) => DietPlan.fromMap(e)).toList();
      }

      return [];
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error al obtener dieta');
      }
      rethrow;
    }
  }

  Future<DietPlan> createDietPlan() async {
    try {
      final response = await _apiClient.client.post('/diet', data: {});
      return DietPlan.fromMap(response.data);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Error al crear dieta');
      }
      rethrow;
    }
  }

  // TODO: Add createDietPlan if needed by frontend
}

final dietRepositoryProvider = Provider<DietRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DietRepository(apiClient);
});

final dietPlanProvider = FutureProvider<DietPlan?>((ref) async {
  final repo = ref.watch(dietRepositoryProvider);
  final plans = await repo.getDietPlans();
  if (plans.isNotEmpty) return plans.first;
  return null;
});
