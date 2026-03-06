import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/routing/app_router.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_list_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/settings_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/list/manage_list_view.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/list/pokemon_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_empty_state.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

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

class _DelayedRepo implements PokemonRepository {
  _DelayedRepo(this._customCompleter);

  final Completer<List<Pokemon>> _customCompleter;

  @override
  Future<List<Pokemon>> loadCustomPokemon() => _customCompleter.future;

  @override
  Future<void> saveCustomPokemon(List<Pokemon> custom) async {}

  @override
  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) async => {};
}

Widget _wrap(
  Widget child, {
  required PokemonRepository repo,
  CounterSync? counterSync,
}) {
  final assetBundle = TestAssetBundle([
    AppAssets.appIcon,
    AppAssets.pokeballIcon,
  ]);
  final store = MemoryKeyValueStore();
  final sync = counterSync ?? FakeCounterSync();
  return DefaultAssetBundle(
    bundle: assetBundle,
    child: MultiProvider(
      providers: [
        Provider<PokemonRepository>.value(value: repo),
        Provider<CounterSync>.value(value: sync),
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

Widget _wrapWithRouter({
  required PokemonRepository repo,
  required GoRouter router,
  CounterSync? counterSync,
}) {
  final assetBundle = TestAssetBundle([
    AppAssets.appIcon,
    AppAssets.pokeballIcon,
  ]);
  final store = MemoryKeyValueStore();
  final sync = counterSync ?? FakeCounterSync();
  return DefaultAssetBundle(
    bundle: assetBundle,
    child: MultiProvider(
      providers: [
        Provider<PokemonRepository>.value(value: repo),
        Provider<CounterSync>.value(value: sync),
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
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
}

void main() {
  testWidgets('shows loading indicator before data loads', (tester) async {
    final repo = _FakeRepo(custom: const [], caught: const {});

    await tester.pumpWidget(_wrap(const PokemonListPage(), repo: repo));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('disposing during async load does not call setState', (
    tester,
  ) async {
    final completer = Completer<List<Pokemon>>();
    final repo = _DelayedRepo(completer);

    await tester.pumpWidget(_wrap(const PokemonListPage(), repo: repo));
    await tester.pumpWidget(const SizedBox.shrink());

    completer.complete(const []);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

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

  testWidgets('stats icon navigates to stats page', (tester) async {
    final repo = _FakeRepo(custom: const [], caught: const {});
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const PokemonListPage(),
        ),
        GoRoute(
          path: AppRoutes.stats,
          builder: (context, state) => const Scaffold(body: Text('Stats Page')),
        ),
      ],
    );

    await tester.pumpWidget(_wrapWithRouter(repo: repo, router: router));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(PokemonListPage.statsKey));
    await tester.pumpAndSettle();

    expect(find.text('Stats Page'), findsOneWidget);
  });

  testWidgets('tapping a pokemon navigates to detail route', (tester) async {
    const pokemon = Pokemon(
      id: '0001',
      name: 'Bulbasaur',
      imagePath: AppAssets.pokeballIcon,
    );
    final repo = _FakeRepo(custom: const [pokemon], caught: const {});
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const PokemonListPage(),
        ),
        GoRoute(
          path: AppRoutes.pokemonDetail,
          builder: (context, state) =>
              const Scaffold(body: Text('Detail Page')),
        ),
      ],
    );

    await tester.pumpWidget(_wrapWithRouter(repo: repo, router: router));
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 40 && find.text('Bulbasaur').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.tap(find.text('Bulbasaur'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Page'), findsOneWidget);
  });

  testWidgets('long press shows edit/delete actions on custom card', (
    tester,
  ) async {
    const pokemon = Pokemon(
      id: 'custom_0001',
      name: 'Bulbasaur',
      imagePath: AppAssets.pokeballIcon,
    );
    final repo = _FakeRepo(custom: const [pokemon], caught: const {});

    await tester.pumpWidget(_wrap(const PokemonListPage(), repo: repo));
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 40 && find.text('Bulbasaur').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final card = find.byType(PokemonCard);
    await tester.longPress(card);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: card, matching: find.byIcon(Icons.edit)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.byIcon(Icons.delete_outline)),
      findsOneWidget,
    );
  });

  testWidgets('manage delete removes pokemon after confirm', (tester) async {
    const pokemon = Pokemon(
      id: 'custom_0001',
      name: 'Bulbasaur',
      imagePath: AppAssets.pokeballIcon,
    );
    final repo = _FakeRepo(custom: const [pokemon], caught: const {});
    final sync = FakeCounterSync();
    await sync.setCounter('counter_custom_0001', 12);
    await sync.setCaught('caught_custom_0001', true);

    await tester.pumpWidget(
      _wrap(const PokemonListPage(), repo: repo, counterSync: sync),
    );
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 40 && find.text('Bulbasaur').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.tap(find.byKey(PokemonListPage.managePokemonKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ManageListView.deleteKey(pokemon.id)));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(PokemonListPage));
    await tester.tap(
      find.text(AppLocalizations.of(context)!.confirmDeleteDelete),
    );
    await tester.pumpAndSettle();

    expect(await repo.loadCustomPokemon(), isEmpty);
    expect(find.byType(PokemonEmptyState), findsOneWidget);
  });
}
