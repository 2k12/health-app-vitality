import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imb_health_app/src/core/theme/app_theme.dart';
import 'package:imb_health_app/src/core/widgets/primary_button.dart';
import '../data/terms_repository.dart';

class TermsAndConditionsScreen extends ConsumerStatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  ConsumerState<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState
    extends ConsumerState<TermsAndConditionsScreen> {
  bool _isAccepted = false;
  bool _isLoading = false;

  final String _legalText = '''
TÉRMINOS Y CONDICIONES Y POLÍTICA DE PRIVACIDAD DE "FITBA CENTER"

Última actualización: 26 de Diciembre de 2025

1. INTRODUCCIÓN Y ALCANCE
Bienvenido a "FitBa Center" (en adelante, la "Aplicación"). Al acceder y utilizar esta Aplicación, usted (el "Usuario") acepta estar legalmente vinculado por los presentes Términos y Condiciones. Esta Aplicación tiene como finalidad el monitoreo de la salud y el desarrollo físico del Usuario, operando bajo las leyes de la República del Ecuador.

2. CUMPLIMIENTO CON LA LOPDP (ECUADOR)
En estricto cumplimiento con la Ley Orgánica de Protección de Datos Personales (LOPDP), publicada en el Quinto Suplemento del Registro Oficial No. 459 del 26 de mayo de 2021, "FitBa Center" garantiza la protección de su información personal.

3. TRATAMIENTO DE DATOS SENSIBLES (SALUD)
El Usuario declara entender que, para el funcionamiento de la Aplicación, se recopilarán DATOS SENSIBLES, definidos en el Art. 4 de la LOPDP como aquellos relativos a la salud, vida sexual, datos biométricos, etc.
Específicamente, se recopilará:
- Medidas corporales (peso, altura, % grasa, etc.).
- Historial de actividad física.
- Datos nutricionales.

FINALIDAD ÚNICA: Estos datos serán utilizados EXCLUSIVAMENTE para:
a) Generar planes de entrenamiento personalizados.
b) Monitorear su progreso físico y de salud.
c) Fines académicos y de investigación estadística anonimizada (si aplica al contexto del proyecto).

4. CONSENTIMIENTO INFORMADO
De conformidad con el Art. 8 de la LOPDP, al marcar la casilla de aceptación, usted otorga su CONSENTIMIENTO LIBRE, ESPECÍFICO, INFORMADO E INEQUÍVOCO para el tratamiento de sus datos personales y sensibles bajo los términos aquí descritos. Usted tiene derecho a revocar este consentimiento en cualquier momento, lo cual implicará la imposibilidad de continuar prestando el servicio de la Aplicación.

5. SEGURIDAD DE LA INFORMACIÓN
"FitBa Center" implementa medidas técnicas y organizativas adecuadas (Art. 39 LOPDP) para garantizar la confidencialidad, integridad y disponibilidad de sus datos, protegiéndolos contra accesos no autorizados, pérdida o destrucción.

6. PROPIEDAD INTELECTUAL
Todo el contenido, diseño (incluyendo la interfaz futurista bajo las leyes de Derechos de Autor), y código fuente son propiedad exclusiva de los desarrolladores de "FitBa Center".

7. CONTACTO
Para ejercer sus derechos ARCO (Acceso, Rectificación, Cancelación y Oposición) previstos en la LOPDP, puede contactar al administrador del sistema dentro de la Aplicación.
''';

  Future<void> _onContinue() async {
    setState(() => _isLoading = true);
    await ref.read(termsRepositoryProvider).acceptTerms();
    // Invalidate the future provider to trigger the redirect logic in the router if it's watching it
    ref.invalidate(termsAcceptedProvider);

    // Explicitly navigate if we are already in the screen
    if (mounted) {
      // Check auth state to decide where to go, or let the router redirect handle it by refreshing.
      // However, since we are inside the builder, manual navigation is often safer after state change.
      // But wait, the router redirect logic will be updated to watch this.
      // For now, let's just push to home/login based on context or let router redirect.
      // We will trust the router refresh.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                          color: primaryColor.withOpacity(0.2), blurRadius: 80)
                    ]),
              )),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Icon(Icons.gavel_outlined,
                      size: 48, color: theme.colorScheme.secondary),
                  const SizedBox(height: 16),
                  Text(
                    'TERMINOS Y CONDICIONES',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: primaryColor,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Terms Container (Glassmorphism)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: primaryColor.withOpacity(0.3)),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              _legalText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Roboto',
                                height: 1.5,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Checkbox
                  GestureDetector(
                    onTap: () => setState(() => _isAccepted = !_isAccepted),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                _isAccepted ? primaryColor : Colors.transparent,
                            border: Border.all(
                                color: _isAccepted ? primaryColor : Colors.grey,
                                width: 2),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: _isAccepted
                                ? [
                                    BoxShadow(
                                        color: primaryColor.withOpacity(0.5),
                                        blurRadius: 10)
                                  ]
                                : [],
                          ),
                          child: _isAccepted
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'LEÍ Y ACEPTO EL TRATAMIENTO DE MIS DATOS SENSIBLES DE SALUD (LOPDP)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  Opacity(
                    opacity: _isAccepted ? 1.0 : 0.5,
                    child: PrimaryButton(
                      text: 'CONTINUE',
                      onPressed: _isAccepted ? _onContinue : null,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
