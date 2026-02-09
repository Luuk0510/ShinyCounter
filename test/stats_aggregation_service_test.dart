import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/counter_state.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/date_range.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/domain/services/stats_aggregation_service.dart';

class _FakeStatsRepository implements StatsRepository {
  _FakeStatsRepository(this._data);

  final StatsSourceData _data;

  @override
  Future<StatsSourceData> loadStatsSource() async => _data;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadStats aggregates summary, games, and recent list', () async {
    final pokemon = [
      const Pokemon(id: 'p1', name: 'One', imagePath: 'a'),
      const Pokemon(id: 'p2', name: 'Two', imagePath: 'b'),
      const Pokemon(id: 'p3', name: 'Three', imagePath: 'c'),
    ];
    final caught = {'p1', 'p2', 'p3'};

    final states = <CounterState>[
      CounterState(
        count: 100,
        isCaught: true,
        caughtGame: 'Alpha',
        caughtAt: DateTime(2024, 1, 2),
        dailyCounts: const {'2024-01-01': 3},
      ),
      CounterState(
        count: 50,
        isCaught: true,
        caughtGame: 'Beta',
        caughtAt: DateTime(2024, 1, 3),
        dailyCounts: const {'2024-01-02': 4},
      ),
      CounterState(
        count: 20,
        isCaught: true,
        caughtGame: 'Beta',
        caughtAt: DateTime(2024, 1, 1),
        dailyCounts: const {'2024-01-03': 5},
      ),
    ];

    final repo = _FakeStatsRepository(
      StatsSourceData(pokemon: pokemon, caught: caught, states: states),
    );
    final service = StatsAggregationService(repository: repo);
    final range = DateRange(
      start: DateTime(2024, 1, 1),
      end: DateTime(2024, 1, 3),
    );

    final snapshot = await service.loadStats(range);
    final summary = snapshot.summary;

    expect(summary.totalPokemon, 3);
    expect(summary.caughtPokemon, 3);
    expect(summary.totalCounts, 170);
    expect(summary.caughtGames.first.game, 'Beta');
    expect(summary.caughtGames.first.count, 2);
    expect(summary.resetsByGame.first.game, 'Alpha');
    expect(summary.resetsByGame.first.count, 100);
    expect(summary.recentCaught.first.pokemon.id, 'p2');

    final counts = summary.dailyTotals.map((e) => e.count).toList();
    expect(counts, [3, 4, 5]);
  });

  test('updateSummaryForRange rebuilds daily totals', () async {
    final service = StatsAggregationService(
      repository: _FakeStatsRepository(
        const StatsSourceData(pokemon: [], caught: {}, states: []),
      ),
    );

    final states = [
      CounterState(
        count: 5,
        isCaught: false,
        dailyCounts: const {'2024-01-02': 4},
      ),
    ];

    final range = DateRange(
      start: DateTime(2024, 1, 2),
      end: DateTime(2024, 1, 2),
    );

    final updated = service.updateSummaryForRange(
      const StatsSummary.empty(),
      states,
      range,
    );

    expect(updated.dailyTotals.length, 1);
    expect(updated.dailyTotals.first.count, 4);
  });
}
