import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/app_locator.dart';
import 'features/pokemon/data/datasources/counter_sync_service.dart';
import 'features/pokemon/domain/repositories/pokemon_repository.dart';
import 'features/pokemon/overlay/counter_overlay.dart' as counter_overlay;
import 'features/pokemon/presentation/pages/pokemon_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocator.instance.init();
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

    return MultiProvider(
      providers: [
        Provider<PokemonRepository>.value(value: AppLocator.instance.pokemonRepository),
        Provider<CounterSyncService>.value(value: AppLocator.instance.counterSyncService),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
