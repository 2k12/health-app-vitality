import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../domain/user_profile.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.client.get('/profile');
      return UserProfile.fromMap(response.data);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error al obtener perfil');
      }
      rethrow;
    }
  }

  Future<void> updateProfile(UserProfile profile, String name) async {
    try {
      final data = profile.toMap();
      data['name'] = name;
      await _apiClient.client.put('/profile', data: data);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['message'] ?? 'Error al actualizar perfil');
      }
      rethrow;
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile();
});
