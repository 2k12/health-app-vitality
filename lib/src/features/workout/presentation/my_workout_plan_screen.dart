import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/workout_repository.dart';
import '../domain/workout_plan.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class MyWorkoutPlanScreen extends ConsumerWidget {
  const MyWorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutPlanAsync = ref.watch(workoutPlanProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Mi Entrenamiento', style: AppTextStyles.headingMedium),
      ),
      body: SafeArea(
        child: workoutPlanAsync.when(
          data: (plan) {
            if (plan == null || plan.dailyRoutines.isEmpty) {
              return _buildEmptyState();
            }
            return _buildPlanContent(plan);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error al cargar rutina: $e',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center,
              size: 80, color: AppColors.textSecondaryLight.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text('Sin rutina asignada',
              style: AppTextStyles.headingMedium
                  .copyWith(color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Text('Tu entrenador actualizará tu plan pronto.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  Widget _buildPlanContent(WorkoutPlan plan) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PLAN ACTIVO',
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...plan.dailyRoutines.entries.map((entry) {
          final day = entry.key;
          final exercises = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text('DÍA $day',
                      style: AppTextStyles.headingLarge
                          .copyWith(color: AppColors.primary)),
                ),
                GlassCard(
                  child: Column(
                    children: [
                      ...exercises.map((e) => Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.fitness_center_outlined,
                                          size: 20,
                                          color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(e.name,
                                              style: AppTextStyles.bodyLarge
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              _Tag(text: '${e.sets} Series'),
                                              const SizedBox(width: 8),
                                              _Tag(text: '${e.reps} Reps'),
                                              if (e.weight != null) ...[
                                                const SizedBox(width: 8),
                                                _Tag(
                                                    text: '${e.weight}kg',
                                                    color: AppColors.accent),
                                              ]
                                            ],
                                          ),
                                          if (e.notes != null &&
                                              e.notes!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                e.notes!,
                                                style: AppTextStyles.caption,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (e != exercises.last)
                                Divider(
                                    height: 1,
                                    color: AppColors.textSecondaryLight
                                        .withOpacity(0.1)),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color? color;

  const _Tag({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color ?? AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
