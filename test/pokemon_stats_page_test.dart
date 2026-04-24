import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/routing/app_router.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/counter_state.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_stats_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_counts_chart.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/game_assets.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

import 'helpers/test_asset_bundle.dart';

class _FakeStatsRepository implements StatsRepository {
  _FakeStatsRepository(this._data);

  final StatsSourceData _data;

  @override
  Future<StatsSourceData> loadStatsSource() async => _data;
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

Widget _wrapStatsApp({
  required GoRouter router,
  required StatsRepository statsRepository,
  required Iterable<String> assetKeys,
}) {
  final assetBundle = TestAssetBundle(assetKeys);
  return DefaultAssetBundle(
    bundle: assetBundle,
    child: MultiProvider(
      providers: [Provider<StatsRepository>.value(value: statsRepository)],
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

Future<void> _scrollUntilFound(
  WidgetTester tester,
  Finder finder, {
  Offset delta = const Offset(0, -420),
}) async {
  final listFinder = find.byType(ListView);
  for (var i = 0; i < 6; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(listFinder, delta);
    await tester.pumpAndSettle();
  }
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
    final statsRepository = _FakeStatsRepository(
      StatsSourceData(
        pokemon: pokemon,
        caught: {'0001', '0002', '0003', '0004'},
        states: states,
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
        statsRepository: statsRepository,
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
    final chartFinder = find.byType(StatsCountsChart);
    await _scrollUntilFound(tester, chartFinder);
    expect(chartFinder, findsOneWidget);

    final context = tester.element(find.byType(PokemonStatsPage));
    final l10n = AppLocalizations.of(context)!;
    await _scrollUntilFound(
      tester,
      find.text(l10n.statsGamesLabel),
      delta: const Offset(0, 420),
    );

    final gamesCard = find.ancestor(
      of: find.text(l10n.statsGamesLabel),
      matching: find.byType(StatsCard),
    );
    final showMore = find.descendant(
      of: gamesCard,
      matching: find.text(l10n.statsGamesShowMore),
    );

    expect(showMore, findsOneWidget);
    await tester.ensureVisible(showMore);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: gamesCard, matching: find.text('Silver')),
      findsNothing,
    );

    await tester.tap(showMore);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: gamesCard, matching: find.text('Silver')),
      findsOneWidget,
    );

    final recentCard = find.ancestor(
      of: find.text(l10n.statsRecentLabel),
      matching: find.byType(StatsCard),
    );
    final bulbasaur = find.descendant(
      of: recentCard,
      matching: find.text('Bulbasaur'),
    );
    expect(bulbasaur, findsOneWidget);
    await tester.ensureVisible(bulbasaur);
    await tester.pumpAndSettle();
    await tester.tap(bulbasaur);
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
    final statsRepository = _FakeStatsRepository(
      StatsSourceData(
        pokemon: const [pokemon],
        caught: const {'0001'},
        states: [
          CounterState(
            count: 42,
            isCaught: true,
            caughtGame: 'Gold',
            caughtAt: now,
            dailyCounts: {dateKey: 2},
          ),
        ],
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
        statsRepository: statsRepository,
        assetKeys: [
          AppAssets.appIcon,
          AppAssets.pokeballIcon,
          GameAssets.logoFor('Gold'),
        ],
      ),
    );

    await _pumpUntilLoaded(tester);

    final context = tester.element(find.byType(PokemonStatsPage));
    final l10n = AppLocalizations.of(context)!;
    final gamesCard = find.ancestor(
      of: find.text(l10n.statsGamesLabel),
      matching: find.byType(StatsCard),
    );
    final goldRow = find.descendant(of: gamesCard, matching: find.text('Gold'));

    await tester.tap(goldRow);
    await tester.pumpAndSettle();

    expect(find.text('Stats Game'), findsOneWidget);
  });
}
