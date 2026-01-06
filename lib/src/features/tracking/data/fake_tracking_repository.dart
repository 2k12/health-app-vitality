import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/measurement.dart';

class FakeTrackingRepository {
  final List<Measurement> _measurements = [];

  Future<void> addMeasurement(Measurement measurement) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _measurements.add(measurement);
  }

  Future<List<Measurement>> getMeasurements(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _measurements.where((m) => m.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

final trackingRepositoryProvider = Provider((ref) => FakeTrackingRepository());

final userMeasurementsProvider =
    FutureProvider.family<List<Measurement>, String>((ref, userId) async {
  final repository = ref.watch(trackingRepositoryProvider);
  return repository.getMeasurements(userId);
});
