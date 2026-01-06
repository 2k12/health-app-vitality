import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/measurement_repository.dart';
import '../domain/user_measurement.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Medidas', style: AppTextStyles.headingMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: historyAsync.when(
          data: (history) {
            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history,
                        size: 64,
                        color: AppColors.textSecondaryLight.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('No hay registros aún',
                        style: AppTextStyles.headingMedium
                            .copyWith(color: AppColors.textSecondaryLight)),
                  ],
                ),
              );
            }

            // Sort by date descending
            final sortedHistory = List<UserMeasurement>.from(history)
              ..sort((a, b) => b.date.compareTo(a.date));

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: sortedHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final m = sortedHistory[index];
                return _MeasurementCard(measurement: m);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
              child: Text('Error al cargar historial: $err',
                  style: TextStyle(color: AppColors.error))),
        ),
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final UserMeasurement measurement;

  const _MeasurementCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'es_ES');
    // Ensure first letter cap if needed or just uppercase
    final dateStr = dateFormat.format(measurement.date).toUpperCase();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
          Divider(
              height: 1, color: AppColors.textSecondaryLight.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DetailItem(
                  label: 'Grasa', value: '${measurement.bodyFat ?? '-'}%'),
              _DetailItem(label: 'Cintura', value: '${measurement.waist} cm'),
              _DetailItem(label: 'Pecho', value: '${measurement.chest} cm'),
              _DetailItem(label: 'Brazo', value: '${measurement.arm} cm'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headingMedium.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
