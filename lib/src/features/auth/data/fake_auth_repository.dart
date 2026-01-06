import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_user.dart';

class FakeAuthRepository extends StateNotifier<AppUser?> {
  FakeAuthRepository() : super(null);

  Future<void> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Hardcoded users for testing
    if (email == 'user@test.com' && password == 'user123') {
      state = const AppUser(
        uid: 'user-123',
        email: 'user@test.com',
        name: 'Cliente Juan',
        role: UserRole.user,
      );
    } else if (email == 'trainer@test.com' && password == 'trainer123') {
      state = const AppUser(
        uid: 'trainer-123',
        email: 'trainer@test.com',
        name: 'Entrenador Pedro',
        role: UserRole.trainer,
      );
    } else if (email == 'admin@test.com' && password == 'admin123') {
      state = const AppUser(
        uid: 'admin-123',
        email: 'admin@test.com',
        name: 'Admin Global',
        role: UserRole.admin,
      );
    } else {
      throw Exception('Credenciales inválidas');
    }
  }

  Future<void> signOut() async {
    state = null;
  }
}

final authRepositoryProvider =
    StateNotifierProvider<FakeAuthRepository, AppUser?>((ref) {
  return FakeAuthRepository();
});
