import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_notifications.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/measurement_repository.dart';
import '../application/health_calculator.dart';
import '../../auth/data/auth_repository.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all measurements
  final _weightController = TextEditingController();
  final _neckController = TextEditingController();
  final _chestController = TextEditingController();
  final _armController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _gluteController = TextEditingController();
  final _legController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with latest data if available (optional, but good UX)
    _loadLatestData();
  }

  Future<void> _loadLatestData() async {
    final latest = await ref.read(latestMeasurementProvider.future);
    if (latest != null && mounted) {
      _weightController.text = latest.weightKg.toString();
      _neckController.text = latest.neck.toString();
      _chestController.text = latest.chest.toString();
      _armController.text = latest.arm.toString();
      _waistController.text = latest.waist.toString();
      _hipsController.text = latest.hips.toString();
      _gluteController.text = latest.glute.toString();
      _legController.text = latest.leg.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _neckController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _gluteController.dispose();
    _legController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Fetch latest measurement to get static bio data (Age, Height, Gender, Goal)
        // If it doesn't exist, we can't properly calculate everything.
        // In a real app, we might handle this differently, but here we assume setup is done.
        final baseMeasurement =
            await ref.read(latestMeasurementProvider.future);

        if (baseMeasurement == null) {
          if (mounted) {
            AppNotifications.showError(
                context, 'Error: Configura tu plan nutricional primero.');
            context.go('/nutrition-setup');
          }
          setState(() => _isLoading = false);
          return;
        }

        // Create new measurement object with updated values
        final newMeasurement = baseMeasurement.copyWith(
          date: _selectedDate,
          weightKg: double.parse(_weightController.text),
          neck: double.parse(_neckController.text),
          chest: double.parse(_chestController.text),
          arm: double.parse(_armController.text),
          waist: double.parse(_waistController.text),
          hips: double.parse(_hipsController.text),
          glute: double.parse(_gluteController.text),
          leg: double.parse(_legController.text),
        );

        // Compute metrics
        final computedMeasurement = HealthCalculator.computeAll(newMeasurement);

        // Save
        await ref
            .read(nutritionalRepositoryProvider)
            .saveMeasurement(computedMeasurement);

        // Invalidate provider
        ref.invalidate(latestMeasurementProvider);

        // Refresh session data to reflect changes immediately
        await ref.read(authRepositoryProvider.notifier).refreshUser();

        if (mounted) {
          AppNotifications.showSuccess(context, 'MEDIDAS REGISTRADAS');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(context, 'Error al guardar: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.black,
              surface: AppTheme.cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              color: AppTheme.scaffoldBackgroundColor,
            ),
          ),
          // Glows
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text('REGISTRAR MEDIDAS',
                      style: TextStyle(letterSpacing: 2.0)),
                  centerTitle: true,
                  elevation: 0,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Date Picker
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'FECHA: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_month,
                                      color: AppTheme.primaryColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Form Fields Grid
                          _buildSectionTitle('BÁSICO'),
                          CustomTextField(
                            label: 'Peso (kg)',
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            prefixIcon: Icons.monitor_weight,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('TORSO'),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Cuello (cm)',
                                  controller: _neckController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (v) =>
                                      v!.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  label: 'Pecho (cm)',
                                  controller: _chestController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (v) =>
                                      v!.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Cintura (cm)',
                                controller: _waistController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (v) =>
                                    v!.isEmpty ? 'Requerido' : null,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 24),

                          _buildSectionTitle('EXTREMIDADES'),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Brazo (cm)',
                                  controller: _armController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (v) =>
                                      v!.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  label: 'Cadera (cm)',
                                  controller: _hipsController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (v) =>
                                      v!.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Gluteo (cm)',
                                  controller: _gluteController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (v) =>
                                      v!.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  label: 'Pierna (cm)',
                                  controller: _legController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (v) =>
                                      v!.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 48),
                          PrimaryButton(
                            text: 'GUARDAR REGISTRO',
                            onPressed: _submit,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.secondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
