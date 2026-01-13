import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/data/auth_repository.dart';
import '../../../../src/shared/widgets/glass_card.dart';
import '../../../../src/core/theme/app_text_styles.dart';
import '../../../../src/core/theme/app_colors.dart';

class UserDashboardScreen extends ConsumerWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider);
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM', 'es_ES').format(now);
    // Capitalize first letter
    final dateDisplay = dateStr[0].toUpperCase() + dateStr.substring(1);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                dateDisplay,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hola, ${user?.name ?? 'Atleta'}',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 32),

              // Activity Summary Title
              const Text(
                'Resumen de Hoy',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 16),

              // Stats Grid
              const Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              color: AppColors.calories, size: 32),
                          SizedBox(height: 12),
                          Text('0', style: AppTextStyles.headingLarge),
                          Text('Kcal Quemadas', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.water_drop_rounded,
                              color: AppColors.hydration, size: 32),
                          SizedBox(height: 12),
                          Text('0', style: AppTextStyles.headingLarge),
                          Text('Vasos de Agua', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Next Workout Card
              const Text(
                'Tu Actividad',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 16),

              GlassCard(
                onTap: () =>
                    context.push('/home/workout'), // Assuming router setup
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fitness_center_rounded,
                          color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ir al Entrenamiento',
                              style: AppTextStyles.headingMedium
                                  .copyWith(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('Ver tu plan del día',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppColors.textSecondaryLight),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              GlassCard(
                onTap: () => context.push('/home/diet'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded,
                          color: AppColors.accent, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plan Nutricional',
                              style: AppTextStyles.headingMedium
                                  .copyWith(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('Revisar comidas de hoy',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppColors.textSecondaryLight),
                  ],
                ),
              ),

              // Logout (Temporary placement)
              const SizedBox(height: 48),
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      ref.read(authRepositoryProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text('Cerrar Sesión',
                      style: AppTextStyles.button
                          .copyWith(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
