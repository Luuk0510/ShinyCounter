import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/app_locator.dart';
import 'core/routing/app_router.dart';
import 'core/theme/tokens.dart';
import 'features/pokemon/data/datasources/counter_sync_service.dart';
import 'features/pokemon/domain/repositories/pokemon_repository.dart';
import 'features/pokemon/overlay/counter_overlay.dart' as counter_overlay;

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
    final router = AppRouter.instance.router;
    return MultiProvider(
      providers: [
        Provider<PokemonRepository>.value(value: AppLocator.instance.pokemonRepository),
        Provider<CounterSyncService>.value(value: AppLocator.instance.counterSyncService),
        Provider.value(value: AppLocator.instance.loadCustomPokemon),
        Provider.value(value: AppLocator.instance.saveCustomPokemon),
        Provider.value(value: AppLocator.instance.loadCaught),
        Provider.value(value: AppLocator.instance.toggleCaught),
      ],
      child: MaterialApp.router(
        title: 'Shiny Counter',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
