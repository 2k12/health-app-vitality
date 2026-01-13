import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/app_user.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/tracking/presentation/history_screen.dart';
import '../features/tracking/presentation/tracking_screen.dart';
import '../features/auth/presentation/terms_screen.dart';
import '../features/auth/data/terms_repository.dart';

import '../features/home/presentation/main_nav_screen.dart';
import '../features/users/presentation/admin_dashboard_screen.dart';
import '../features/users/presentation/trainer_dashboard_screen.dart';
import '../features/trainer/presentation/workout_plan_form_screen.dart';

import '../features/workout/presentation/client_detail_screen.dart';
import '../features/tracking/presentation/nutritional_setup_screen.dart';
import '../features/diet/presentation/my_diet_screen.dart';
import '../features/workout/presentation/my_workout_plan_screen.dart';

// --- Placeholder screens (Pantallas temporales) ---
// (Placeholders deleted as they are now implemented)

// --- Configuración del Router ---

import 'go_router_refresh_stream.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Use refreshListenable to trigger redirects without rebuilding the Router
  final authNotifier = ref.watch(authRepositoryProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    redirect: (context, state) {
      // Use ref.read to get current state without watching
      final authState = ref.read(authRepositoryProvider);
      final termsAccepted = ref.read(termsAcceptedProvider);

      final isTermsRoute = state.uri.path == '/terms';
      final isLoggedIn = authState != null;
      final isLoggingIn = state.uri.path == '/';

      // 0. If terms NOT accepted AND Logged In, FORCE /terms
      if (isLoggedIn && !termsAccepted) {
        if (!isTermsRoute) return '/terms';
        return null;
      }

      // 1. If terms ACCEPTED and trying to access /terms, redirect to home
      if (termsAccepted && isTermsRoute) {
        return isLoggedIn ? '/home' : '/';
      }

      // 2. Si NO está logueado y no está en el login, mandarlo al login
      if (!isLoggedIn) {
        return isLoggingIn ? null : '/';
      }

      // 3. Si YA está logueado e intenta ir al login, mandarlo a su home según rol
      if (isLoggingIn) {
        switch (authState.role) {
          case UserRole.admin:
            return '/admin-panel';
          case UserRole.trainer:
            return '/trainer-dashboard';
          case UserRole.user:
            return '/home';
        }
      }

      // 4. Protección de Rutas por Rol (Role Guards)
      if (isLoggedIn) {
        final path = state.uri.path;

        // Admin Routes Protection
        if (path.startsWith('/admin-panel')) {
          if (authState.role != UserRole.admin) {
            // Usuario normal o trainer intentando entrar a admin -> Home/Dashboard respectivo
            return authState.role == UserRole.trainer
                ? '/trainer-dashboard'
                : '/home';
          }
        }

        // Trainer Routes Protection
        if (path.startsWith('/trainer')) {
          if (authState.role != UserRole.trainer &&
              authState.role != UserRole.admin) {
            // Usuario normal intentando ver cosas de trainer
            return '/home';
          }
        }

        // Prevent Admins/Trainers from accidentally landing on User Home
        if (path == '/home' || path.startsWith('/home/')) {
          if (authState.role == UserRole.admin) return '/admin-panel';
          if (authState.role == UserRole.trainer) return '/trainer-dashboard';
        }
      }

      return null;
    },
    routes: [
      // Terms Screen
      GoRoute(
        path: '/terms',
        pageBuilder: (context, state) => _buildTransitionPage(
            context, state, const TermsAndConditionsScreen()),
      ),

      // Ruta Login
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            _buildTransitionPage(context, state, const LoginScreen()),
      ),

      // Ruta Dashboard Usuario (Home)
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            _buildTransitionPage(context, state, const MainNavScreen()),
        routes: [
          // Sub-ruta Historial
          GoRoute(
            path: 'history',
            pageBuilder: (context, state) =>
                _buildTransitionPage(context, state, const HistoryScreen()),
          ),
          // Sub-ruta Dieta
          GoRoute(
            path: 'diet',
            pageBuilder: (context, state) =>
                _buildTransitionPage(context, state, const MyDietScreen()),
          ),
          // Sub-ruta Rutina
          GoRoute(
            path: 'workout',
            pageBuilder: (context, state) => _buildTransitionPage(
                context, state, const MyWorkoutPlanScreen()),
          ),
        ],
      ),

      // Ruta para agregar nuevo registro
      GoRoute(
        path: '/tracking/new',
        pageBuilder: (context, state) =>
            _buildTransitionPage(context, state, const TrackingScreen()),
      ),

      // Ruta Entrenador
      GoRoute(
        path: '/trainer-dashboard',
        pageBuilder: (context, state) => _buildTransitionPage(
            context, state, const TrainerDashboardScreen()),
      ),

      // Ruta Detalle Cliente (para entrenador)
      GoRoute(
        path: '/trainer/client/:uid',
        pageBuilder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return _buildTransitionPage(
              context, state, ClientDetailScreen(clientId: uid));
        },
      ),

      // Ruta Formulario Plan de Entrenamiento
      GoRoute(
        path: '/trainer/workout-form/:uid',
        pageBuilder: (context, state) {
          final uid = state.pathParameters['uid']!;
          final userName = state.extra as String?;
          return _buildTransitionPage(context, state,
              WorkoutPlanFormScreen(userId: uid, userName: userName));
        },
      ),

      // Ruta Admin
      GoRoute(
        path: '/admin-panel',
        pageBuilder: (context, state) =>
            _buildTransitionPage(context, state, const AdminDashboardScreen()),
      ),

      // Ruta Nutrition Setup
      GoRoute(
        path: '/nutrition-setup',
        pageBuilder: (context, state) => _buildTransitionPage(
            context, state, const NutritionalSetupScreen()),
      ),
    ],
  );
});

CustomTransitionPage<void> _buildTransitionPage(
    BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    barrierDismissible: true,
    barrierColor: Colors.black38,
    opaque: false,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Custom Fade + Slide Transition
      const begin = Offset(0.0, 0.05); // Subtle slide from slightly below
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      var fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: child,
        ),
      );
    },
  );
}
