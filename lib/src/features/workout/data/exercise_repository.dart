import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import '../domain/exercise.dart';

class ExerciseRepository {
  final ApiClient _apiClient;

  ExerciseRepository(this._apiClient);

  Future<List<Exercise>> getExercises() async {
    final response = await _apiClient.client.get('/exercises');
    return (response.data as List).map((e) => Exercise.fromMap(e)).toList();
  }

  Future<List<Exercise>> getExercisesByMuscle(String muscle) async {
    final response = await _apiClient.client.get('/exercises/muscle/$muscle');
    return (response.data as List).map((e) => Exercise.fromMap(e)).toList();
  }
}

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ref.watch(apiClientProvider));
});

final allExercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getExercises();
});
