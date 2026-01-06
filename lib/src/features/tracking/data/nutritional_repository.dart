import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_measurement.dart';

// Provider for the storage service
final nutritionalRepositoryProvider = Provider<NutritionalRepository>((ref) {
  return NutritionalRepository();
});

// Stream/Future provider for the latest measurement
final latestMeasurementProvider = FutureProvider<UserMeasurement?>((ref) async {
  final repo = ref.watch(nutritionalRepositoryProvider);
  return repo.getLatestMeasurement();
});

class NutritionalRepository {
  static const _keyLatestMeasurement = 'latest_nutritional_setup_v1';
  static const _keyHistory = 'nutritional_history_v1';

  /// Saves a measurement.
  /// 1. Updates the "latest" key for quick access.
  /// 2. Appends to the "history" list.
  Future<void> saveMeasurement(UserMeasurement measurement) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Save Latest
    final jsonString = jsonEncode(measurement.toMap());
    await prefs.setString(_keyLatestMeasurement, jsonString);

    // 2. Append to History
    final historyList = prefs.getStringList(_keyHistory) ?? [];
    historyList.add(jsonString);
    await prefs.setStringList(_keyHistory, historyList);
  }

  Future<UserMeasurement?> getLatestMeasurement() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyLatestMeasurement);
    if (jsonString == null) return null;

    try {
      final map = jsonDecode(jsonString);
      return UserMeasurement.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  Future<List<UserMeasurement>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList(_keyHistory) ?? [];

    return historyList
        .map((str) {
          try {
            return UserMeasurement.fromMap(jsonDecode(str));
          } catch (e) {
            return null;
          }
        })
        .whereType<UserMeasurement>()
        .toList(); // Filter nulls
  }
}

final historyProvider = FutureProvider<List<UserMeasurement>>((ref) async {
  final repo = ref.watch(nutritionalRepositoryProvider);
  return repo.getHistory();
});
