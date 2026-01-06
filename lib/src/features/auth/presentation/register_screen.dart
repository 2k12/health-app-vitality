import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/utils/app_validators.dart';
import '../../../../src/core/utils/app_notifications.dart';
import '../../../../src/shared/widgets/vital_button.dart';
import '../../../../src/shared/widgets/vital_input.dart';
import '../../../../src/shared/widgets/glass_card.dart';
import '../../../../src/core/theme/app_text_styles.dart';

// Note: You'll need to implement the signUp method in AuthRepository
import '../data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        AppNotifications.showError(context, 'Las contraseñas no coinciden');
        return;
      }

      setState(() => _isLoading = true);
      try {
        // Implement SignUp in repository
        await ref.read(authRepositoryProvider.notifier).signUp(
              _emailController.text.trim(),
              _passwordController.text.trim(),
              _nameController.text.trim(),
            );

        if (!mounted) return;
        AppNotifications.showSuccess(context, 'Cuenta creada exitosamente');
        context.go('/login'); // Or auto-login
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(context, e.toString());
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Cuenta',
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Únete para transformar tu estilo de vida',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        VitalInput(
                          label: 'Nombre Completo',
                          hintText: 'Tu nombre',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              v != null && v.isNotEmpty ? null : 'Requerido',
                        ),
                        const SizedBox(height: 24),
                        VitalInput(
                          label: 'Email',
                          hintText: 'ejemplo@correo.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: AppValidators.isValidEmail,
                        ),
                        const SizedBox(height: 24),
                        VitalInput(
                          label: 'Contraseña',
                          hintText: 'Mínimo 6 caracteres',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: AppValidators.isValidPassword,
                        ),
                        const SizedBox(height: 24),
                        VitalInput(
                          label: 'Confirmar Contraseña',
                          hintText: 'Repite tu contraseña',
                          controller: _confirmPasswordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Requerido';
                            if (val != _passwordController.text) {
                              return 'No coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        VitalButton(
                          label: 'REGISTRARSE',
                          onPressed: _submit,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Ingresa aquí'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
