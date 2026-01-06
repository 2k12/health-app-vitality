import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/utils/app_validators.dart';
import '../../../../src/core/utils/app_notifications.dart';
import '../../../../src/shared/widgets/vital_button.dart';
import '../../../../src/shared/widgets/vital_input.dart';
import '../../../../src/shared/widgets/glass_card.dart';
import '../../../../src/core/theme/app_colors.dart';
import '../../../../src/core/theme/app_text_styles.dart';
import '../data/auth_repository.dart';
import '../data/terms_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authRepositoryProvider.notifier).signIn(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );

        final termsRepo = ref.read(termsRepositoryProvider);
        final hasAccepted = await termsRepo.hasAcceptedTerms();

        if (!mounted) return;

        if (!hasAccepted) {
          context.go('/terms');
        } else {
          context.go('/home');
        }
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / Title
                const Icon(
                  Icons.fitness_center_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenido',
                  style: AppTextStyles.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa a tu cuenta para continuar tu progreso',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Form
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                          hintText: '********',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: AppValidators.isValidPassword,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement Forgot Password
                            },
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        VitalButton(
                          label: 'INGRESAR',
                          onPressed: _submit,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      child: const Text('Regístrate'),
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
