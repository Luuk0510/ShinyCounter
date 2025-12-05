import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shiny_counter/core/routing/app_router.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/features/pokemon/data/repositories/prefs_pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

class _FakePokemonRepository extends PrefsPokemonRepository {
  final List<Pokemon> seed;
  _FakePokemonRepository(this.seed);

  @override
  Future<List<Pokemon>> loadCustomPokemon() async => seed;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('navigates to detail when pokemon extra provided', (
    tester,
  ) async {
    final repo = _FakePokemonRepository([
      const Pokemon(
        id: 'p-pika',
        name: 'Pikachu',
        imagePath: 'assets/icon/pokeball_icon.png',
      ),
    ]);
    final sync = await CounterSyncService.instance();
    final loadCustom = LoadCustomPokemonUseCase(repo);
    final saveCustom = SaveCustomPokemonUseCase(repo);
    final loadCaught = LoadCaughtUseCase(repo);
    final toggleCaught = ToggleCaughtUseCase(sync);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: repo),
          Provider.value(value: sync),
          Provider.value(value: loadCustom),
          Provider.value(value: saveCustom),
          Provider.value(value: loadCaught),
          Provider.value(value: toggleCaught),
          Provider<SpriteService>.value(value: SpriteRepository()),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ],
        child: MaterialApp.router(
          routerConfig: AppRouter.instance.router,
          supportedLocales: const [Locale('en'), Locale('nl')],
          locale: const Locale('nl'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Pokémon shiny counter'), findsOneWidget);

    const pokemon = Pokemon(
      id: 'p-test',
      name: 'Testmon',
      imagePath: 'assets/icon/pokeball_icon.png',
    );
    AppRouter.instance.router.go(AppRoutes.pokemonDetail, extra: pokemon);
    await tester.pumpAndSettle();

    expect(find.text('Testmon'), findsOneWidget);
  });
}
