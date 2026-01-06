import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';

import 'core/theme/app_theme.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el router provider que creaste en la carpeta routing
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Medidas App',
      theme: AppTheme.darkTheme,
      routerConfig: goRouter, // Conexión con GoRouter
    );
  }
}
