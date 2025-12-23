import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/routing/app_router.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_stats_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_counts_chart.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/game_assets.dart';
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

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

Widget _wrapStatsApp({
  required GoRouter router,
  required PokemonRepository repo,
  required CounterSync sync,
  required Iterable<String> assetKeys,
}) {
  final assetBundle = TestAssetBundle(assetKeys);
  return DefaultAssetBundle(
    bundle: assetBundle,
    child: MultiProvider(
      providers: [
        Provider<PokemonRepository>.value(value: repo),
        Provider<LoadCustomPokemonUseCase>(
          create: (_) => LoadCustomPokemonUseCase(repo),
        ),
        Provider<LoadCaughtUseCase>(create: (_) => LoadCaughtUseCase(repo)),
        Provider<CounterSync>.value(value: sync),
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

Future<void> _pumpUntilLoaded(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 40; i++) {
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('stats page shows summary, games, recent, and chart', (
    tester,
  ) async {
    final now = DateTime.now();
    final dateKey = _dateKey(now);
    final pokemon = [
      const Pokemon(
        id: '0001',
        name: 'Bulbasaur',
        imagePath: AppAssets.pokeballIcon,
      ),
      const Pokemon(
        id: '0002',
        name: 'Ivysaur',
        imagePath: AppAssets.pokeballIcon,
      ),
      const Pokemon(
        id: '0003',
        name: 'Venusaur',
        imagePath: AppAssets.pokeballIcon,
      ),
      const Pokemon(
        id: '0004',
        name: 'Charmander',
        imagePath: AppAssets.pokeballIcon,
      ),
    ];
    final repo = _FakeRepo(
      custom: pokemon,
      caught: {'0001', '0002', '0003', '0004'},
    );
    final sync = FakeCounterSync();
    final states = [
      CounterState(
        count: 10,
        isCaught: true,
        caughtGame: 'Gold',
        caughtAt: now,
        dailyCounts: {dateKey: 3},
      ),
      CounterState(
        count: 20,
        isCaught: true,
        caughtGame: 'Silver',
        caughtAt: now.subtract(const Duration(days: 1)),
        dailyCounts: {dateKey: 4},
      ),
      CounterState(
        count: 30,
        isCaught: true,
        caughtGame: 'Crystal',
        caughtAt: now.subtract(const Duration(days: 2)),
        dailyCounts: {dateKey: 5},
      ),
      CounterState(
        count: 40,
        isCaught: true,
        caughtGame: 'Ruby',
        caughtAt: now.subtract(const Duration(days: 3)),
        dailyCounts: {dateKey: 6},
      ),
    ];
    for (var i = 0; i < pokemon.length; i++) {
      final keys = CounterKeys.fromId(pokemon[i].id);
      await sync.saveState(keys.counter, keys.caught, states[i]);
    }

    final router = GoRouter(
      initialLocation: AppRoutes.stats,
      routes: [
        GoRoute(
          path: AppRoutes.stats,
          builder: (context, state) => const PokemonStatsPage(),
        ),
        GoRoute(
          path: AppRoutes.statsGame,
          builder: (context, state) => const Scaffold(body: Text('Stats Game')),
        ),
        GoRoute(
          path: AppRoutes.pokemonDetail,
          builder: (context, state) =>
              const Scaffold(body: Text('Pokemon Detail')),
        ),
      ],
    );

    await tester.pumpWidget(
      _wrapStatsApp(
        router: router,
        repo: repo,
        sync: sync,
        assetKeys: [
          AppAssets.appIcon,
          AppAssets.pokeballIcon,
          GameAssets.logoFor('Gold'),
          GameAssets.logoFor('Silver'),
          GameAssets.logoFor('Crystal'),
          GameAssets.logoFor('Ruby'),
        ],
      ),
    );

    await _pumpUntilLoaded(tester);

    expect(find.text('4 / 4'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.byType(StatsCountsChart, skipOffstage: false), findsOneWidget);

    final context = tester.element(find.byType(PokemonStatsPage));
    final l10n = AppLocalizations.of(context)!;
    final gamesCard = find.ancestor(
      of: find.text(l10n.statsGamesLabel),
      matching: find.byType(StatsCard),
    );
    final showMore = find.descendant(
      of: gamesCard,
      matching: find.text(l10n.statsGamesShowMore),
    );

    expect(showMore, findsOneWidget);
    expect(find.text('Silver'), findsNothing);

    await tester.tap(showMore);
    await tester.pumpAndSettle();

    expect(find.text('Silver'), findsOneWidget);

    await tester.tap(find.text('Bulbasaur'));
    await tester.pumpAndSettle();

    expect(find.text('Pokemon Detail'), findsOneWidget);
  });

  testWidgets('tapping a game row opens game stats page', (tester) async {
    final now = DateTime.now();
    final dateKey = _dateKey(now);
    const pokemon = Pokemon(
      id: '0001',
      name: 'Bulbasaur',
      imagePath: AppAssets.pokeballIcon,
    );
    final repo = _FakeRepo(custom: const [pokemon], caught: const {'0001'});
    final sync = FakeCounterSync();
    final keys = CounterKeys.fromId('0001');
    await sync.saveState(
      keys.counter,
      keys.caught,
      CounterState(
        count: 42,
        isCaught: true,
        caughtGame: 'Gold',
        caughtAt: now,
        dailyCounts: {dateKey: 2},
      ),
    );

    final router = GoRouter(
      initialLocation: AppRoutes.stats,
      routes: [
        GoRoute(
          path: AppRoutes.stats,
          builder: (context, state) => const PokemonStatsPage(),
        ),
        GoRoute(
          path: AppRoutes.statsGame,
          builder: (context, state) => const Scaffold(body: Text('Stats Game')),
        ),
      ],
    );

    await tester.pumpWidget(
      _wrapStatsApp(
        router: router,
        repo: repo,
        sync: sync,
        assetKeys: [
          AppAssets.appIcon,
          AppAssets.pokeballIcon,
          GameAssets.logoFor('Gold'),
        ],
      ),
    );

    await _pumpUntilLoaded(tester);

    await tester.tap(find.text('Gold'));
    await tester.pumpAndSettle();

    expect(find.text('Stats Game'), findsOneWidget);
  });
}
