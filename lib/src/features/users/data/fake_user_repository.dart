import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/user_profile.dart';

/// A combined state to hold both users and their profiles for this mock.
class UserDataState {
  final List<AppUser> users;
  final List<UserProfile> profiles;

  const UserDataState({required this.users, required this.profiles});

  UserDataState copyWith({
    List<AppUser>? users,
    List<UserProfile>? profiles,
  }) {
    return UserDataState(
      users: users ?? this.users,
      profiles: profiles ?? this.profiles,
    );
  }
}

class FakeUserRepository extends StateNotifier<UserDataState> {
  FakeUserRepository() : super(_initialState());

  static UserDataState _initialState() {
    // 1. Mock Users
    final users = [
      const AppUser(
          uid: 'user-123',
          email: 'user@test.com',
          name: 'Cliente Juan',
          role: UserRole.user),
      const AppUser(
          uid: 'u2',
          email: 'maria@test.com',
          name: 'Maria Lopez',
          role: UserRole.user),
      const AppUser(
          uid: 'u3',
          email: 'carlos@test.com',
          name: 'Carlos Ruiz',
          role: UserRole.user),
      const AppUser(
          uid: 'trainer-123',
          email: 'trainer@test.com',
          name: 'Entrenador Pedro',
          role: UserRole.trainer),
      const AppUser(
          uid: 't2',
          email: 'laura@test.com',
          name: 'Entrenadora Laura',
          role: UserRole.trainer),
    ];

    // 2. Mock Profiles (Only for regular users mainly)
    final profiles = [
      const UserProfile(
        userId: 'user-123',
        age: 30,
        gender: Gender.male,
        height: 175,
        weight: 75,
        activityLevel: ActivityLevel.moderate,
        fitnessGoal: FitnessGoal.buildMuscle,
        assignedTrainerId: null, // No trainer initially
      ),
      const UserProfile(
        userId: 'u2',
        age: 25,
        gender: Gender.female,
        height: 165,
        weight: 60,
        activityLevel: ActivityLevel.active,
        fitnessGoal: FitnessGoal.loseWeight,
        assignedTrainerId: 'trainer-123', // Already has Pedro
      ),
      const UserProfile(
        userId: 'u3',
        age: 40,
        gender: Gender.male,
        height: 180,
        weight: 90,
        activityLevel: ActivityLevel.sedentary,
        fitnessGoal: FitnessGoal.loseWeight,
        assignedTrainerId: null, // No trainer
      ),
    ];

    return UserDataState(users: users, profiles: profiles);
  }

  /// Assigns a trainer to a specific user.
  Future<void> assignTrainer(String userId, String trainerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final currentProfiles = state.profiles;
    final index = currentProfiles.indexWhere((p) => p.userId == userId);

    if (index != -1) {
      final updatedProfile =
          currentProfiles[index].copyWith(assignedTrainerId: trainerId);

      // Update state immutably
      final newProfiles = [...currentProfiles];
      newProfiles[index] = updatedProfile;

      state = state.copyWith(profiles: newProfiles);
    }
  }

  // Getters for filtered lists (Optional helper methods, but logic will be in Providers)
}

final userRepositoryProvider =
    StateNotifierProvider<FakeUserRepository, UserDataState>((ref) {
  return FakeUserRepository();
});

// --- Derived Providers for the UI ---

/// Returns a list of Users (AppUser) who do NOT have a trainer assigned.
final usersWithoutTrainerProvider = Provider<List<AppUser>>((ref) {
  final data = ref.watch(userRepositoryProvider);

  // Find profile userIds that have null trainer
  final userIdsWithoutTrainer = data.profiles
      .where((p) => p.assignedTrainerId == null)
      .map((p) => p.userId)
      .toSet();

  // Filter AppUsers who are in that set AND are role 'user'
  return data.users
      .where((u) =>
          u.role == UserRole.user && userIdsWithoutTrainer.contains(u.uid))
      .toList();
});

/// Returns a list of all Trainers.
final trainersProvider = Provider<List<AppUser>>((ref) {
  final data = ref.watch(userRepositoryProvider);
  return data.users.where((u) => u.role == UserRole.trainer).toList();
});

/// Returns a list of Users assigned to a specific Trainer ID.
final usersByTrainerProvider =
    Provider.family<List<AppUser>, String>((ref, trainerId) {
  final data = ref.watch(userRepositoryProvider);

  // Find profile userIds assigned to this trainer
  final userIdsAssigned = data.profiles
      .where((p) => p.assignedTrainerId == trainerId)
      .map((p) => p.userId)
      .toSet();

  return data.users.where((u) => userIdsAssigned.contains(u.uid)).toList();
});
