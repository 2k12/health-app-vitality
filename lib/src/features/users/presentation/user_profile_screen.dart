import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/vital_button.dart';
import '../../../shared/widgets/vital_input.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../core/utils/app_notifications.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/profile_repository.dart';
import '../../auth/domain/user_profile.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final bool useScaffold;
  const UserProfileScreen({super.key, this.useScaffold = true});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final user = ref.read(authRepositoryProvider);
    _nameController.text = user?.name ?? '';

    try {
      final profile = await ref.read(userProfileProvider.future);
      setState(() {
        _currentProfile = profile;
        _ageController.text = profile.age.toString();
        _heightController.text = profile.height.toString();
        _weightController.text = profile.weight.toString();
      });
    } catch (e) {
      // Handle error cleanly
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      final updatedProfile = (_currentProfile ??
              UserProfile(
                userId: '',
                age: 0,
                gender: Gender.male,
                height: 0,
                weight: 0,
                activityLevel: ActivityLevel.moderate,
                fitnessGoal: FitnessGoal.maintenance,
              ))
          .copyWith(
        age: int.tryParse(_ageController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
      );

      await ref
          .read(profileRepositoryProvider)
          .updateProfile(updatedProfile, name);
      await ref.read(authRepositoryProvider.notifier).refreshUser();
      ref.invalidate(userProfileProvider);

      if (mounted) {
        AppNotifications.showSuccess(
            context, 'Perfil actualizado correctamente');
        _toggleEdit();
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(context, 'Error al actualizar: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    final content = profileAsync.when(
      data: (profile) => _buildContent(context, profile),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error al cargar perfil')),
    );

    if (widget.useScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mi Perfil', style: AppTextStyles.headingMedium),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: _toggleEdit,
              ),
          ],
        ),
        body: content,
      );
    }
    return content;
  }

  Widget _buildContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Avatar Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : 'U',
                    style: AppTextStyles.displayMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEditing ? 'Editando Perfil' : _nameController.text,
                  style: AppTextStyles.headingMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _isEditing ? _buildEditForm() : _buildViewMode(profile),
        ],
      ),
    );
  }

  Widget _buildViewMode(UserProfile profile) {
    return Column(
      children: [
        _InfoRow(
            icon: Icons.cake_outlined,
            label: 'Edad',
            value: '${profile.age} años'),
        const SizedBox(height: 16),
        _InfoRow(
            icon: Icons.height, label: 'Altura', value: '${profile.height} cm'),
        const SizedBox(height: 16),
        _InfoRow(
            icon: Icons.monitor_weight_outlined,
            label: 'Peso',
            value: '${profile.weight} kg'),
        const SizedBox(height: 48),
        VitalButton(
          label: 'CERRAR SESIÓN',
          type: VitalButtonType.danger,
          onPressed: () => ref.read(authRepositoryProvider.notifier).signOut(),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return GlassCard(
      child: Column(
        children: [
          VitalInput(
            label: 'Nombre Display',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          VitalInput(
            label: 'Edad',
            controller: _ageController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.cake_outlined,
          ),
          const SizedBox(height: 16),
          VitalInput(
            label: 'Altura (cm)',
            controller: _heightController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.height,
          ),
          const SizedBox(height: 16),
          VitalInput(
            label: 'Peso (kg)',
            controller: _weightController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 32),
          VitalButton(
            label: 'GUARDAR CAMBIOS',
            isLoading: _isSaving,
            onPressed: _saveChanges,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _toggleEdit,
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondaryLight)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryLight)),
          const Spacer(),
          Text(value, style: AppTextStyles.headingMedium),
        ],
      ),
    );
  }
}
