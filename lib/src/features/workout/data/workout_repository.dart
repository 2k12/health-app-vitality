import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../domain/workout_plan.dart';

class WorkoutRepository {
  final ApiClient _apiClient;

  WorkoutRepository(this._apiClient);

  Future<List<WorkoutPlan>> getWorkoutPlans() async {
    try {
      final response = await _apiClient.client.get('/workout');
      final List<dynamic> list = response.data;
      return list.map((e) => WorkoutPlan.fromMap(e)).toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error al obtener rutina');
      }
      rethrow;
    }
  }

  Future<void> addWorkout(WorkoutPlan plan) async {
    try {
      await _apiClient.client.post('/workout', data: plan.toMap());

      // Optionally invalidate provider
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error al asignar rutina');
      }
      rethrow;
    }
  }
}

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WorkoutRepository(apiClient);
});

final workoutPlanProvider = FutureProvider<WorkoutPlan?>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final plans = await repo.getWorkoutPlans();
  if (plans.isNotEmpty) return plans.first;
  return null;
});

final userWorkoutsProvider =
    FutureProvider.family<List<WorkoutPlan>, String>((ref, userId) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final allPlans = await repo.getWorkoutPlans();
  // Filter by userId to ensure we only show relevant plans
  return allPlans.where((p) => p.userId == userId).toList();
});
