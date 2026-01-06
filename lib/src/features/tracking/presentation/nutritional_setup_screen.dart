import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/vital_button.dart';
import '../../../shared/widgets/vital_input.dart';
import '../../../shared/widgets/glass_card.dart';

import '../domain/user_measurement.dart';
import '../application/health_calculator.dart';
import '../data/measurement_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/profile_repository.dart';
import '../../diet/data/diet_repository.dart';

class NutritionalSetupScreen extends StatefulWidget {
  const NutritionalSetupScreen({super.key});

  @override
  State<NutritionalSetupScreen> createState() => _NutritionalSetupScreenState();
}

class _NutritionalSetupScreenState extends State<NutritionalSetupScreen> {
  final PageController _pageController = PageController();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  int _currentStep = 0;

  // Data State
  Gender _gender = Gender.male;
  final TextEditingController _ageController =
      TextEditingController(text: '25');
  final TextEditingController _heightController =
      TextEditingController(text: '170');
  final TextEditingController _weightController =
      TextEditingController(text: '70');

  UserGoal _goal = UserGoal.maintenance;
  int _trainingDays = 3;

  // Measurements Controllers
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipsController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _armController = TextEditingController();
  final TextEditingController _gluteController = TextEditingController();
  final TextEditingController _legController = TextEditingController();

  double _heightSliderValue = 170;

  @override
  void initState() {
    super.initState();
    // Sync slider with text controller
    _heightController.addListener(() {
      final val = double.tryParse(_heightController.text);
      if (val != null && val >= 100 && val <= 230) {
        setState(() => _heightSliderValue = val);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _gluteController.dispose();
    _legController.dispose();
    super.dispose();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      if (!_formKeyStep1.currentState!.validate()) return;
    }

    if (_currentStep == 2) {
      if (!_formKeyStep3.currentState!.validate()) return;
      _calculateAndFinish();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  void _calculateAndFinish() {
    // Parse values
    final age = int.tryParse(_ageController.text) ?? 25;
    final weight = double.tryParse(_weightController.text) ?? 70;
    final height = double.tryParse(_heightController.text) ?? 170;

    final neck = double.tryParse(_neckController.text) ?? 0;
    final waist = double.tryParse(_waistController.text) ?? 0;
    final hips = double.tryParse(_hipsController.text) ?? 0;
    final chest = double.tryParse(_chestController.text) ?? 0;
    final arm = double.tryParse(_armController.text) ?? 0;
    final glute = double.tryParse(_gluteController.text) ?? 0;
    final leg = double.tryParse(_legController.text) ?? 0;

    // Create Object
    final rawData = UserMeasurement(
        date: DateTime.now(),
        age: age,
        gender: _gender,
        heightCm: height,
        weightKg: weight,
        goal: _goal,
        trainingDays: _trainingDays,
        neck: neck,
        chest: chest,
        arm: arm,
        waist: waist,
        hips: hips,
        glute: glute,
        leg: leg);

    final result = HealthCalculator.computeAll(rawData);

    _showResultDialog(result);
  }

  void _showResultDialog(UserMeasurement result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: GlassCard(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_graph, color: AppColors.accent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'PLAN CALCULADO',
                  style: AppTextStyles.headingMedium.copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: 24),
                _buildResultRow('Grasa Corporal', '${result.bodyFat ?? '-'}%'),
                _buildResultRow('BMR', '${result.bmr} kcal'),
                _buildResultRow('TDEE', '${result.tdee} kcal'),
                Divider(
                    color: AppColors.surfaceLight.withOpacity(0.24),
                    height: 32),
                _buildResultRow('OBJETIVO', '${result.targetCalories} kcal',
                    isHighlight: true),
                const SizedBox(height: 32),
                Consumer(builder: (context, ref, _) {
                  return VitalButton(
                      label: 'GUARDAR Y FINALIZAR',
                      onPressed: () async {
                        // Save to repository using Riverpod
                        await ref
                            .read(nutritionalRepositoryProvider)
                            .saveMeasurement(result);

                        // Invalidate providers to force refresh
                        ref.invalidate(latestMeasurementProvider);
                        ref.invalidate(historyProvider);
                        ref.invalidate(userProfileProvider);

                        // Refresh session data
                        await ref
                            .read(authRepositoryProvider.notifier)
                            .refreshUser();

                        // Generate and sync new Diet Plan
                        try {
                          await ref
                              .read(dietRepositoryProvider)
                              .createDietPlan();
                          ref.invalidate(dietPlanProvider);
                        } catch (e) {
                          debugPrint('Error creating diet plan: $e');
                        }

                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          context
                              .go('/home/diet'); // Go directly to diet screen
                        }
                      });
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryLight)),
          Text(value,
              style: isHighlight
                  ? AppTextStyles.headingMedium
                      .copyWith(color: AppColors.accent)
                  : AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('CONFIGURACIÓN',
            style: AppTextStyles.headingMedium.copyWith(letterSpacing: 2.0)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.indigoTint, // Subtle Indigo tint
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: List.generate(3, (index) {
                    final isActive = index <= _currentStep;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),

              // Navigation Bar
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 100,
                          child: VitalButton(
                            type: VitalButtonType.secondary,
                            label: 'ATRÁS',
                            isFullWidth: true,
                            onPressed: () {
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease);
                              setState(() => _currentStep--);
                            },
                          ),
                        ),
                      ),
                    Expanded(
                      child: VitalButton(
                        label: _currentStep == 2 ? 'CALCULAR' : 'SIGUIENTE',
                        onPressed: _nextStep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGETS FOR STEPS

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Biometría Básica',
                style: AppTextStyles.headingLarge
                    .copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(
                'Necesitamos tus datos base para calcular tu perfil metabólico.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondaryLight)),
            const SizedBox(height: 32),
            GlassCard(
              child: Column(
                children: [
                  // Gender Toggle
                  Row(
                    children: [
                      Expanded(
                          child: _buildGenderOption(
                              Gender.male, Icons.male, 'Hombre')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildGenderOption(
                              Gender.female, Icons.female, 'Mujer')),
                    ],
                  ),
                  const SizedBox(height: 32),

                  VitalInput(
                    label: 'Edad',
                    hintText: '25',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    suffixIcon: const Icon(Icons.cake_outlined, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (int.tryParse(v) == null) return 'Inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  VitalInput(
                    label: 'Peso (kg)',
                    hintText: '70.5',
                    controller: _weightController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    suffixIcon:
                        const Icon(Icons.monitor_weight_outlined, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (double.tryParse(v) == null) return 'Inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Height Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Altura', style: AppTextStyles.bodyLarge),
                      Text('${_heightSliderValue.round()} cm',
                          style: AppTextStyles.headingMedium
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _heightSliderValue,
                    min: 100,
                    max: 230,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withOpacity(0.2),
                    onChanged: (v) {
                      setState(() => _heightSliderValue = v);
                      _heightController.text = v.round().toString();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(Gender g, IconData icon, String label) {
    final isSelected = _gender == g;
    return GestureDetector(
      onTap: () => setState(() => _gender = g),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
            ]),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tus Objetivos',
              style: AppTextStyles.headingLarge
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Define qué quieres lograr para personalizar tu plan.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryLight)),
          const SizedBox(height: 32),
          _buildGoalOption(
              'Ganancia Muscular', 'Hypertrofia y fuerza', UserGoal.gain),
          const SizedBox(height: 12),
          _buildGoalOption(
              'Definición', 'Quema de grasa y tono', UserGoal.definition),
          const SizedBox(height: 12),
          _buildGoalOption(
              'Mantenimiento', 'Salud y energía', UserGoal.maintenance),
          const SizedBox(height: 48),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Días de Entrenamiento', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Semanal', style: AppTextStyles.bodyMedium),
                    Text('$_trainingDays días',
                        style: AppTextStyles.headingMedium
                            .copyWith(color: AppColors.accent)),
                  ],
                ),
                Slider(
                  value: _trainingDays.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  activeColor: AppColors.accent,
                  onChanged: (v) => setState(() => _trainingDays = v.round()),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoalOption(String title, String subtitle, UserGoal g) {
    final isSelected = _goal == g;
    return GestureDetector(
      onTap: () => setState(() => _goal = g),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.headingMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimaryLight,
                          fontSize: 16)),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary)
            else
              Icon(Icons.circle_outlined, color: AppColors.textSecondaryLight)
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeyStep3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Medidas Corporales',
                style: AppTextStyles.headingLarge
                    .copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Opcional, pero recomendado para mayor precisión.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondaryLight)),
            const SizedBox(height: 32),
            GlassCard(
              child: Column(
                children: [
                  VitalInput(
                      label: 'Cuello (cm)',
                      controller: _neckController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  VitalInput(
                      label: 'Cintura (cm)',
                      controller: _waistController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  if (_gender == Gender.female) ...[
                    VitalInput(
                        label: 'Caderas (cm)',
                        controller: _hipsController,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                  ],
                  VitalInput(
                      label: 'Pecho (cm)',
                      controller: _chestController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  VitalInput(
                      label: 'Brazo (cm)',
                      controller: _armController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  VitalInput(
                      label: 'Glúteo (cm)',
                      controller: _gluteController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  VitalInput(
                      label: 'Pierna (cm)',
                      controller: _legController,
                      keyboardType: TextInputType.number),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
