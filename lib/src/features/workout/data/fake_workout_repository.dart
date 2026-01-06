import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/workout_plan.dart';

class FakeWorkoutRepository extends StateNotifier<List<WorkoutPlan>> {
  FakeWorkoutRepository() : super([]);

  Future<void> addWorkout(WorkoutPlan plan) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    state = [...state, plan];
  }

  List<WorkoutPlan> getWorkoutsForUser(String userId) {
    return state.where((p) => p.userId == userId).toList();
  }
}

final fakeWorkoutRepositoryProvider =
    StateNotifierProvider<FakeWorkoutRepository, List<WorkoutPlan>>((ref) {
  return FakeWorkoutRepository();
});

final fakeUserWorkoutsProvider =
    Provider.family<List<WorkoutPlan>, String>((ref, userId) {
  final workouts = ref.watch(fakeWorkoutRepositoryProvider);
  return workouts.where((w) => w.userId == userId).toList();
});
