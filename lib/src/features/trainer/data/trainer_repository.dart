import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../../auth/domain/app_user.dart';
import '../../workout/domain/workout_plan.dart';

class TrainerRepository {
  final ApiClient _apiClient;

  TrainerRepository(this._apiClient);

  Future<List<AppUser>> getAssignedUsers() async {
    try {
      final response = await _apiClient.client.get('/trainer/users');
      final List<dynamic> data = response.data;
      return data.map((json) => AppUser.fromMap(json)).toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error fetching assigned users');
      }
      throw Exception('Unexpected error: $e');
    }
  }

  Future<WorkoutPlan?> getUserWorkoutPlan(String userId) async {
    try {
      final response =
          await _apiClient.client.get('/trainer/workout-plan/$userId');
      if (response.statusCode == 404) return null;
      return WorkoutPlan.fromMap(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) return null;
        throw Exception(
            e.response?.data['message'] ?? 'Error fetching workout plan');
      }
      throw Exception('Unexpected error: $e');
    }
  }

  Future<WorkoutPlan> upsertWorkoutPlan(
      String userId, dynamic exercises) async {
    try {
      final response =
          await _apiClient.client.post('/trainer/workout-plan', data: {
        'userId': userId,
        'exercises': exercises,
      });
      return WorkoutPlan.fromMap(response.data);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error saving workout plan');
      }
      throw Exception('Unexpected error: $e');
    }
  }
}

final trainerRepositoryProvider = Provider<TrainerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TrainerRepository(apiClient);
});

final assignedUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  final repository = ref.watch(trainerRepositoryProvider);
  return repository.getAssignedUsers();
});

final userWorkoutPlanProvider =
    FutureProvider.family<WorkoutPlan?, String>((ref, userId) async {
  final repository = ref.watch(trainerRepositoryProvider);
  return repository.getUserWorkoutPlan(userId);
});
