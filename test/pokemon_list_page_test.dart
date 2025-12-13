import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_list_page.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

import 'helpers/fakes.dart';
import 'helpers/test_asset_bundle.dart';

class _FakeRepo implements PokemonRepository {
  _FakeRepo({required List<Pokemon> custom, required Set<String> caught})
    : _custom = List<Pokemon>.from(custom),
      _caught = Set<String>.from(caught);

  final List<Pokemon> _custom;
  final Set<String> _caught;

  @override
  Future<List<Pokemon>> loadCustomPokemon() async => List.unmodifiable(_custom);

  @override
  Future<void> saveCustomPokemon(List<Pokemon> custom) async {
    _custom
      ..clear()
      ..addAll(custom);
  }

  @override
  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) async =>
      Set.unmodifiable(_caught);
}

Widget _wrap(Widget child, {required PokemonRepository repo}) {
  final assetBundle = TestAssetBundle([
    AppAssets.appIcon,
    AppAssets.pokeballIcon,
  ]);
  return DefaultAssetBundle(
    bundle: assetBundle,
    child: MultiProvider(
      providers: [
        Provider<PokemonRepository>.value(value: repo),
        Provider<LoadCustomPokemonUseCase>(
          create: (_) => LoadCustomPokemonUseCase(repo),
        ),
        Provider<SaveCustomPokemonUseCase>(
          create: (_) => SaveCustomPokemonUseCase(repo),
        ),
        Provider<LoadCaughtUseCase>(create: (_) => LoadCaughtUseCase(repo)),
        Provider<SpriteService>(
          create: (_) => FakeSpriteService(const <ParsedSprite>[]),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('collapses and expands uncaught/caught sections', (tester) async {
    const a = Pokemon(id: '0001', name: 'Bulbasaur', imagePath: 'a.png');
    const b = Pokemon(id: '0002', name: 'Ivysaur', imagePath: 'b.png');
    const c = Pokemon(id: '0003', name: 'Venusaur', imagePath: 'c.png');
    final repo = _FakeRepo(custom: const [a, b, c], caught: {'0003'});

    await tester.pumpWidget(_wrap(const PokemonListPage(), repo: repo));
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 40 && find.text('Uncaught').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Both sections visible.
    expect(find.text('Uncaught'), findsOneWidget);
    expect(find.text('Caught'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Ivysaur'), findsOneWidget);
    expect(find.text('Venusaur'), findsOneWidget);

    // Uncaught rotation starts expanded (turns 0.5).
    final beforeRotation = tester
        .widgetList<AnimatedRotation>(find.byType(AnimatedRotation))
        .first;
    expect(beforeRotation.turns, 0.5);

    // Collapse uncaught.
    await tester.tap(find.text('Uncaught'));
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsNothing);
    expect(find.text('Ivysaur'), findsNothing);
    expect(find.text('Venusaur'), findsOneWidget);

    final afterRotation = tester
        .widgetList<AnimatedRotation>(find.byType(AnimatedRotation))
        .first;
    expect(afterRotation.turns, 0);

    // Expand uncaught again.
    await tester.tap(find.text('Uncaught'));
    await tester.pumpAndSettle();
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Ivysaur'), findsOneWidget);
  });
}
