import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/shared/services/stats_aggregation_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

class _FakePokemonRepository implements PokemonRepository {
  _FakePokemonRepository(this._pokemon, this._caught);

  final List<Pokemon> _pokemon;
  final Set<String> _caught;

  @override
  Future<List<Pokemon>> loadCustomPokemon() async => _pokemon;

  @override
  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) async => _caught;

  @override
  Future<void> saveCustomPokemon(List<Pokemon> custom) async {}
}

class _FakeCounterSync implements CounterSync {
  _FakeCounterSync(this._states);

  final Map<String, CounterState> _states;

  @override
  Stream<dynamic> get overlayStream => const Stream.empty();

  @override
  Future<CounterState> loadState(String counterKey, String caughtKey) async {
    return _states[counterKey] ?? const CounterState(count: 0, isCaught: false);
  }

  @override
  Future<void> saveState(
    String counterKey,
    String caughtKey,
    CounterState state,
  ) async {}

  @override
  Future<void> clearPokemonState(String pokemonId) async {}

  @override
  Future<void> setCounter(String counterKey, int count) async {}

  @override
  Future<void> setCaught(String caughtKey, bool isCaught) async {}

  @override
  Future<void> setStartedAt(String counterKey, DateTime? startedAt) async {}

  @override
  Future<void> setCaughtAt(String counterKey, DateTime? caughtAt) async {}

  @override
  Future<void> setCaughtGame(String counterKey, String? game) async {}

  @override
  Future<void> clearHuntDates(String counterKey) async {}

  @override
  Future<void> setDailyCounts(
    String counterKey,
    Map<String, int> counts,
  ) async {}

  @override
  Future<bool> ensureOverlay(
    CounterOverlayMessage message, {
    int width = 360,
    int height = 220,
  }) async => false;

  @override
  Future<void> showOverlay(
    CounterOverlayMessage message, {
    int width = 360,
    int height = 220,
  }) async {}

  @override
  Future<bool> isOverlayActive() async => false;

  @override
  Future<void> shareToOverlay(CounterOverlayMessage message) async {}

  @override
  Future<void> closeOverlay() async {}
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

    final states = <String, CounterState>{
      CounterKeys.fromId('p1').counter: CounterState(
        count: 100,
        isCaught: true,
        caughtGame: 'Alpha',
        caughtAt: DateTime(2024, 1, 2),
        dailyCounts: const {'2024-01-01': 3},
      ),
      CounterKeys.fromId('p2').counter: CounterState(
        count: 50,
        isCaught: true,
        caughtGame: 'Beta',
        caughtAt: DateTime(2024, 1, 3),
        dailyCounts: const {'2024-01-02': 4},
      ),
      CounterKeys.fromId('p3').counter: CounterState(
        count: 20,
        isCaught: true,
        caughtGame: 'Beta',
        caughtAt: DateTime(2024, 1, 1),
        dailyCounts: const {'2024-01-03': 5},
      ),
    };

    final repo = _FakePokemonRepository(pokemon, caught);
    final service = StatsAggregationService(
      loadCustomPokemon: LoadCustomPokemonUseCase(repo),
      loadCaught: LoadCaughtUseCase(repo),
      sync: _FakeCounterSync(states),
    );
    final range = DateTimeRange(
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
    expect(summary.recentCaught.first.pokemon.id, 'p2');

    final counts = summary.dailyTotals.map((e) => e.count).toList();
    expect(counts, [3, 4, 5]);
  });

  test('updateSummaryForRange rebuilds daily totals', () async {
    final service = StatsAggregationService(
      loadCustomPokemon: LoadCustomPokemonUseCase(
        _FakePokemonRepository(const [], const {}),
      ),
      loadCaught: LoadCaughtUseCase(_FakePokemonRepository(const [], const {})),
      sync: _FakeCounterSync(const {}),
    );

    final states = [
      CounterState(
        count: 5,
        isCaught: false,
        dailyCounts: const {'2024-01-02': 4},
      ),
    ];

    final range = DateTimeRange(
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
