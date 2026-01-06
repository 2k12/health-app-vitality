import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Asegurate que la ruta sea correcta según tu nombre de proyecto
import 'src/app.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  runApp(
    // ProviderScope es OBLIGATORIO para Riverpod
    const ProviderScope(
      child: MainApp(),
    ),
  );
}
