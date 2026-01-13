import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../src/core/theme/app_colors.dart';
import '../../../../src/core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../tracking/domain/user_measurement.dart';
import '../data/admin_repository.dart';

class AdminUserHistoryScreen extends ConsumerWidget {
  final String userId;
  final String userName;

  const AdminUserHistoryScreen(
      {super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(userMeasurementsProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background Effects (Vitality Style)
          Container(
            color: bgColor,
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: AppColors.textPrimaryLight),
                      ),
                      Expanded(
                        child: Text(
                          'HISTORIAL: ${userName.toUpperCase()}',
                          style: AppTextStyles.headingMedium.copyWith(
                            letterSpacing: 1.5,
                            fontSize: 18,
                            color: AppColors.textPrimaryLight,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: historyAsync.when(
                    data: (measurements) {
                      if (measurements.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_toggle_off,
                                  size: 64,
                                  color: AppColors.textSecondaryLight),
                              const SizedBox(height: 16),
                              Text(
                                'No hay registros aún.',
                                style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        );
                      }

                      // Sort by date desc
                      final sorted = List<UserMeasurement>.from(measurements)
                        ..sort((a, b) => b.date.compareTo(a.date));

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sorted.length,
                        itemBuilder: (context, index) {
                          final measurement = sorted[index];
                          return _HistoryCard(measurement: measurement)
                              .animate()
                              .fadeIn(
                                  duration: 400.ms,
                                  delay: Duration(milliseconds: 100 * index))
                              .slideX(begin: 0.1, curve: Curves.easeOut);
                        },
                      );
                    },
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Text('Error: $err',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final UserMeasurement measurement;

  const _HistoryCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date & Weight
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(measurement.date),
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 16,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.5)),
                  ),
                  child: Text(
                    '${measurement.weightKg} KG',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Divider(color: AppColors.surfaceLight.withOpacity(0.1), height: 24),

            // Stats Grid
            _buildGrid(context),

            // Body Fat Indicator
            if (measurement.bodyFat != null && measurement.bodyFat! > 0) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Grasa Corporal',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondaryLight)),
                  Text('${measurement.bodyFat!.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (measurement.bodyFat ?? 0) /
                      50, // Assuming max 50% for scale
                  backgroundColor: AppColors.surfaceLight.withOpacity(0.1),
                  color: AppColors.secondary,
                  minHeight: 6,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      // 3 items per row approx
      final itemWidth = (width - 24) / 3;

      return Wrap(
        spacing: 12,
        runSpacing: 16,
        children: [
          _statItem('Cintura', measurement.waist, itemWidth),
          _statItem('Pecho', measurement.chest, itemWidth),
          _statItem('Brazo', measurement.arm, itemWidth),
          _statItem('Pierna', measurement.leg, itemWidth),
          _statItem('Cadera', measurement.hips, itemWidth),
          if (measurement.glute != null && measurement.glute! > 0)
            _statItem('Glúteo', measurement.glute!, itemWidth),
        ],
      );
    });
  }

  Widget _statItem(String label, double? value, double width) {
    final val = value ?? 0;
    if (val == 0) return const SizedBox.shrink();

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondaryLight, fontSize: 11)),
          const SizedBox(height: 4),
          Text('${val.toStringAsFixed(1)} cm',
              style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight)),
        ],
      ),
    );
  }
}
