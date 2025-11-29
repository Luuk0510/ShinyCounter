import 'package:flutter/material.dart';

import 'pokemon_list_page.dart';
import 'counter_overlay.dart' as counter_overlay;

void main() {
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void overlayMain() {
  counter_overlay.overlayMain();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    final darkSchemeBase = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );
    final darkScheme = darkSchemeBase.copyWith(
      background: const Color(0xFF151924),
      surface: const Color(0xFF1E2430),
      surfaceVariant: const Color(0xFF252C3A),
    );

    return MaterialApp(
      title: 'Shiny Counter',
      theme: ThemeData(
        colorScheme: lightScheme,
        scaffoldBackgroundColor: lightScheme.background,
        cardTheme: CardThemeData(
          color: lightScheme.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        scaffoldBackgroundColor: darkScheme.background,
        cardTheme: CardThemeData(
          color: darkScheme.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const PokemonListPage(),
    );
  }
}
