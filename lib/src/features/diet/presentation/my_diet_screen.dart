import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../tracking/data/measurement_repository.dart';
import '../../tracking/domain/user_measurement.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/vital_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/diet_repository.dart';
import '../domain/diet_models.dart';

class MyDietScreen extends ConsumerStatefulWidget {
  const MyDietScreen({super.key});

  @override
  ConsumerState<MyDietScreen> createState() => _MyDietScreenState();
}

class _MyDietScreenState extends ConsumerState<MyDietScreen> {
  int _selectedDay = 1; // 1 = Lunes

  @override
  Widget build(BuildContext context) {
    final measurementAsync = ref.watch(latestMeasurementProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Plan Nutricional', style: AppTextStyles.headingMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        // Usamos SafeArea para evitar superposición con OS UI
        bottom: false,
        child: measurementAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
              child: Text('Error: $err',
                  style: TextStyle(color: AppColors.error))),
          data: (measurement) {
            if (measurement == null) {
              return _buildEmptyState();
            }

            // Macros calculation
            final calories = measurement.targetCalories ?? 2000;
            final proteinCals = calories * 0.30;
            final carbCals = calories * 0.40;
            final fatCals = calories * 0.30;
            final proteinG = (proteinCals / 4).round();
            final carbG = (carbCals / 4).round();
            final fatG = (fatCals / 9).round();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Stats
                  _buildDailyGoalCard(calories.round(), measurement.goal),
                  const SizedBox(height: 16),

                  // Macros Grid
                  Row(
                    children: [
                      Expanded(
                          child: _MacroCard(
                              label: 'Proteína',
                              value: '${proteinG}g',
                              color: AppColors.accent,
                              icon: Icons.fitness_center)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _MacroCard(
                              label: 'Carbos',
                              value: '${carbG}g',
                              color: AppColors.chartCarbs,
                              icon: Icons.bolt)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _MacroCard(
                              label: 'Grasas',
                              value: '${fatG}g',
                              color: AppColors.chartFat,
                              icon: Icons.opacity)),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text('Plan Semanal', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 16),

                  // Day Selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        final isSelected = day == _selectedDay;
                        final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = day),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 44,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.4),
                                          blurRadius: 8)
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(days[index],
                                    style: AppTextStyles.caption.copyWith(
                                        color: isSelected
                                            ? AppColors.textPrimaryLight
                                            : AppColors.textSecondaryLight,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.textPrimaryLight
                                        : Colors.transparent,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Meal Plan Data
                  Consumer(builder: (context, ref, _) {
                    final dietPlanAsync = ref.watch(dietPlanProvider);
                    return dietPlanAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                      data: (plan) {
                        if (plan == null || plan.meals.isEmpty) {
                          return _buildNoPlanState();
                        }

                        final dailyMeals = plan.meals
                            .where((m) => m.day == _selectedDay)
                            .toList();

                        if (dailyMeals.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('Descanso o ayuno programado.',
                                  style: TextStyle(
                                      color: AppColors.textSecondaryLight)),
                            ),
                          );
                        }

                        return Column(
                          children: dailyMeals.asMap().entries.map((entry) {
                            final index = entry.key;
                            final meal = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildMealCard(meal),
                            )
                                .animate()
                                .fadeIn(delay: (index * 100).ms)
                                .slideX();
                          }).toList(),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 24),
                  VitalButton(
                    label: 'RECALCULAR PLAN',
                    type: VitalButtonType.secondary,
                    onPressed: () => context.push('/nutrition-setup'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_rounded,
              size: 64, color: AppColors.textSecondaryLight.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Sin objetivos nutricionales',
              style: AppTextStyles.headingMedium),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: VitalButton(
              label: 'CONFIGURAR AHORA',
              onPressed: () => context.push('/nutrition-setup'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlanState() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Plan no generado', style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          Text('Genera un menú semanal basado en tus macros.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryLight)),
          const SizedBox(height: 24),
          VitalButton(
            label: 'GENERAR DIETA',
            onPressed: () async {
              try {
                await ref.read(dietRepositoryProvider).createDietPlan();
                ref.invalidate(dietPlanProvider);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(int calories, UserGoal goal) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OBJETIVO DIARIO',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('$calories kcal', style: AppTextStyles.displayMedium),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
            ),
            child: Text(
              _getGoalLabel(goal),
              style:
                  AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(DietMeal meal) {
    double totalCalories = 0;
    for (var df in meal.foods) {
      totalCalories += (df.portionGram / 100) * df.food.calories;
    }

    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.textSecondaryLight.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(meal.name.toUpperCase(),
                    style: AppTextStyles.headingMedium.copyWith(fontSize: 16)),
                Text('${totalCalories.round()} kcal',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: meal.foods
                  .map((food) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: AppColors.textSecondaryLight,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(food.food.name,
                                    style: AppTextStyles.bodyMedium)),
                            Text('${food.portionGram}g',
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getGoalLabel(UserGoal goal) {
    switch (goal) {
      case UserGoal.gain:
        return 'VOLUMEN';
      case UserGoal.definition:
        return 'DEFINICIÓN';
      case UserGoal.maintenance:
        return 'MANTENIMIENTO';
    }
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MacroCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.headingMedium.copyWith(fontSize: 20)),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
