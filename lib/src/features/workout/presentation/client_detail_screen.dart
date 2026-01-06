import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../tracking/data/measurement_repository.dart';
import '../../trainer/data/trainer_repository.dart';
import '../../workout/domain/workout_plan.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(userMeasurementsProvider(clientId));
    final workoutPlanAsync = ref.watch(userWorkoutPlanProvider(clientId));

    // We try to find the user in the assigned users list to get their name
    final usersAsync = ref.watch(assignedUsersProvider);
    final user = usersAsync.whenOrNull(
      data: (users) => users.firstWhere((u) => u.uid == clientId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(user?.name ?? 'Detalle del Cliente'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orangeAccent.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('PROGRESO BIOMÉTRICO'),
              const SizedBox(height: 16),
              measurementsAsync.when(
                data: (data) {
                  if (data.isEmpty) {
                    return _buildEmptyState('Sin registros de medidas aún');
                  }
                  return _buildMeasurementsList(data);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: Colors.redAccent)),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildSectionHeader('PLAN DE ENTRENAMIENTO')),
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Colors.cyanAccent, size: 20),
                    onPressed: () => context.push(
                      '/trainer/workout-form/$clientId',
                      extra: user?.name,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              workoutPlanAsync.when(
                data: (plan) {
                  if (plan == null) {
                    return _buildEmptyState('No hay un plan asignado');
                  }
                  return _buildWorkoutPlan(plan);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent,
        onPressed: () => context.push(
          '/trainer/workout-form/$clientId',
          extra: user?.name,
        ),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Gestionar Plan',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: Colors.white10, thickness: 0.5)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline,
              color: Colors.white.withOpacity(0.2), size: 40),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.white.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _buildMeasurementsList(List<dynamic> measurements) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: measurements.length > 5 ? 5 : measurements.length,
      itemBuilder: (context, index) {
        final m = measurements[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${m.date.day}/${m.date.month}/${m.date.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${m.weightKg} kg',
                  style: const TextStyle(
                      color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              Text('BF: ${m.bodyFat?.toStringAsFixed(1) ?? "--"}%',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutPlan(WorkoutPlan plan) {
    if (plan.dailyRoutines.isEmpty) return _buildEmptyState('Plan vacío');

    return Column(
      children: plan.dailyRoutines.entries.map((entry) {
        final day = entry.key;
        final exercises = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DÍA $day',
                      style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  if (day == 1)
                    Text(
                        'Actualizado: ${plan.createdAt.day}/${plan.createdAt.month}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10)),
                ],
              ),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              ...exercises.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 6, color: Colors.cyanAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  '${e.sets} series x ${e.reps} reps ${e.weight != null ? "@ ${e.weight}kg" : ""}',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }
}
