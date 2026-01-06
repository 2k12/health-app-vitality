import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'HISTORIAL: ${userName.toUpperCase()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: historyAsync.when(
        data: (measurements) {
          if (measurements.isEmpty) {
            return const Center(
              child: Text('No hay medidas registradas para este usuario.'),
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
                  .fadeIn(delay: Duration(milliseconds: 100 * index))
                  .slideX(begin: 0.1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final UserMeasurement measurement;

  const _HistoryCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppTheme.secondaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(measurement.date),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    '${measurement.weightKg} KG',
                    style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            _buildGrid(context),
            if (measurement.bodyFat != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (measurement.bodyFat ?? 0) / 100,
                backgroundColor: Colors.white10,
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Grasa Corporal: ${measurement.bodyFat?.toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _statItem('Cintura', measurement.waist),
        _statItem('Pecho', measurement.chest),
        _statItem('Brazo', measurement.arm),
        _statItem('Pierna', measurement.leg),
        _statItem('Cadera', measurement.hips),
      ],
    );
  }

  Widget _statItem(String label, double value) {
    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withOpacity(0.5))),
          Text('${value.toStringAsFixed(1)} cm',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
