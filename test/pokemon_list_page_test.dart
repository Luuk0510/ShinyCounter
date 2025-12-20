import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_list_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/settings_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/list/manage_list_view.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_empty_state.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/l10n/app_localizations.dart';

import 'helpers/fakes.dart';
import 'helpers/memory_store.dart';
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
  final store = MemoryKeyValueStore();
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
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(store),
        ),
        ChangeNotifierProvider<LocaleNotifier>(
          create: (_) => LocaleNotifier(store),
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
    const a = Pokemon(
      id: '0001',
      name: 'Bulbasaur',
      imagePath: AppAssets.pokeballIcon,
    );
    const b = Pokemon(
      id: '0002',
      name: 'Ivysaur',
      imagePath: AppAssets.pokeballIcon,
    );
    const c = Pokemon(
      id: '0003',
      name: 'Venusaur',
      imagePath: AppAssets.pokeballIcon,
    );
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

  testWidgets('shows empty state when no pokemon exist', (tester) async {
    final repo = _FakeRepo(custom: const [], caught: const {});

    await tester.pumpWidget(_wrap(const PokemonListPage(), repo: repo));
    await tester.pump(const Duration(milliseconds: 300));
    for (
      var i = 0;
      i < 40 && find.byType(PokemonEmptyState).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(PokemonEmptyState), findsOneWidget);
  });

  testWidgets('manage icon shows snackbar when no custom pokemon', (
    tester,
  ) async {
    final repo = _FakeRepo(custom: const [], caught: const {});

    await tester.pumpWidget(_wrap(const PokemonListPage(), repo: repo));
    await tester.pump(const Duration(milliseconds: 300));
    for (
      var i = 0;
      i < 40 && find.byType(PokemonEmptyState).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.tap(find.byKey(PokemonListPage.managePokemonKey));
    await tester.pump();

    final context = tester.element(find.byType(PokemonListPage));
    expect(
      find.text(AppLocalizations.of(context)!.manageNoCustom),
      findsOneWidget,
    );
  });

  testWidgets('manage icon opens list when custom pokemon exist', (
    tester,
  ) async {
    const a = Pokemon(
      id: '0001',
      name: 'Bulbasaur',
      imagePath: AppAssets.pokeballIcon,
    );
    final repo = _FakeRepo(custom: const [a], caught: const {});

    await tester.pumpWidget(_wrap(const PokemonListPage(), repo: repo));
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 40 && find.text('Uncaught').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.tap(find.byKey(PokemonListPage.managePokemonKey));
    await tester.pumpAndSettle();

    expect(find.byType(ManageListView), findsOneWidget);
  });

  testWidgets('settings icon opens settings dialog', (tester) async {
    final repo = _FakeRepo(custom: const [], caught: const {});

    await tester.pumpWidget(_wrap(const PokemonListPage(), repo: repo));
    await tester.pump(const Duration(milliseconds: 300));
    for (
      var i = 0;
      i < 40 && find.byType(PokemonEmptyState).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.tap(find.byKey(PokemonListPage.settingsKey));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsDialog), findsOneWidget);
  });
}
