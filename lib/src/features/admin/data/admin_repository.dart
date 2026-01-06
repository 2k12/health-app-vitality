import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../../diet/domain/diet_models.dart';
import '../../auth/domain/app_user.dart';
import '../../tracking/domain/user_measurement.dart';

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository(this._apiClient);

  // Users & Trainers
  Future<List<AppUser>> getAllUsers() async {
    final response = await _apiClient.client.get('/admin/users');
    return (response.data as List).map((e) => AppUser.fromMap(e)).toList();
  }

  Future<List<AppUser>> getAllTrainers() async {
    final response = await _apiClient.client.get('/admin/trainers');
    return (response.data as List).map((e) => AppUser.fromMap(e)).toList();
  }

  Future<void> assignTrainer(String userId, String? trainerId) async {
    await _apiClient.client.post('/admin/assign-trainer', data: {
      'userId': userId,
      'trainerId': trainerId,
    });
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    await _apiClient.client.patch('/admin/users/$userId/status', data: {
      'isActive': isActive,
    });
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _apiClient.client.post('/admin/users', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  // Foods
  Future<List<FoodItem>> getAllFoods() async {
    final response = await _apiClient.client.get('/foods');
    return (response.data as List).map((e) => FoodItem.fromMap(e)).toList();
  }

  Future<void> createFood(Map<String, dynamic> foodData) async {
    await _apiClient.client.post('/foods', data: foodData);
  }

  Future<void> updateFood(String id, Map<String, dynamic> foodData) async {
    await _apiClient.client.put('/foods/$id', data: foodData);
  }

  Future<void> deleteFood(String id) async {
    await _apiClient.client.delete('/foods/$id');
  }

  // Diet
  Future<void> generateDietPlanForUser(String userId) async {
    await _apiClient.client.post('/diet', data: {'userId': userId});
  }

  // Measurements
  Future<List<UserMeasurement>> getUserMeasurements(String userId) async {
    final response = await _apiClient.client.get('/measurements/user/$userId');
    return (response.data as List)
        .map((e) => UserMeasurement.fromMap(e))
        .toList();
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(apiClientProvider));
});

final allUsersProvider =
    FutureProvider((ref) => ref.watch(adminRepositoryProvider).getAllUsers());
final allTrainersProvider = FutureProvider(
    (ref) => ref.watch(adminRepositoryProvider).getAllTrainers());
final allFoodsProvider =
    FutureProvider((ref) => ref.watch(adminRepositoryProvider).getAllFoods());

final userMeasurementsProvider =
    FutureProvider.family<List<UserMeasurement>, String>((ref, userId) {
  return ref.watch(adminRepositoryProvider).getUserMeasurements(userId);
});
