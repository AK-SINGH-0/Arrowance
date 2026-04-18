import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrowance/features/splash/splash_screen.dart';
import 'package:arrowance/features/gameplay/theme/game_theme.dart';

import 'package:arrowance/data/storage/hive_service.dart';
import 'package:arrowance/game/state/game_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const ArrowanceApp(),
    ),
  );
}

class ArrowanceApp extends StatelessWidget {
  const ArrowanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrowance',
      debugShowCheckedModeBanner: false,
      theme: buildGameTheme(),
      home: const SplashScreen(),
    );
  }
}
