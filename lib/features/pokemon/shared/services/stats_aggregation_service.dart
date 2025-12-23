import 'package:flutter/material.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

class StatsSnapshot {
  const StatsSnapshot({required this.summary, required this.states});

  final StatsSummary summary;
  final List<CounterState> states;
}

class StatsAggregationService {
  StatsAggregationService({
    required LoadCustomPokemonUseCase loadCustomPokemon,
    required LoadCaughtUseCase loadCaught,
    required CounterSync sync,
  }) : _loadCustomPokemon = loadCustomPokemon,
       _loadCaught = loadCaught,
       _sync = sync;

  final LoadCustomPokemonUseCase _loadCustomPokemon;
  final LoadCaughtUseCase _loadCaught;
  final CounterSync _sync;

  Future<StatsSnapshot> loadStats(DateTimeRange range) async {
    final pokemon = await _loadCustomPokemon();
    final caught = await _loadCaught(pokemon);
    final states = await Future.wait(
      pokemon.map((p) {
        final keys = CounterKeys.fromId(p.id);
        return _sync.loadState(keys.counter, keys.caught);
      }),
    );

    final summary = _buildSummary(
      pokemonCount: pokemon.length,
      caughtCount: caught.length,
      states: states,
      range: range,
      pokemonNames: pokemon,
    );

    return StatsSnapshot(summary: summary, states: states);
  }

  StatsSummary updateSummaryForRange(
    StatsSummary summary,
    List<CounterState> states,
    DateTimeRange range,
  ) {
    return summary.copyWith(dailyTotals: buildDailyTotals(states, range));
  }

  StatsSummary _buildSummary({
    required int pokemonCount,
    required int caughtCount,
    required List<CounterState> states,
    required DateTimeRange range,
    required List<Pokemon> pokemonNames,
  }) {
    final totalCounts = states.fold<int>(0, (sum, state) => sum + state.count);
    final caughtByGame = <String, int>{};
    final caughtEntriesByGame = <String, List<PokemonCaughtEntry>>{};
    final recentCaught = <PokemonCaughtEntry>[];

    for (var i = 0; i < states.length; i++) {
      final state = states[i];
      if (!state.isCaught) continue;
      final game = state.caughtGame;
      if (game != null && game.isNotEmpty) {
        caughtByGame.update(game, (value) => value + 1, ifAbsent: () => 1);
        caughtEntriesByGame
            .putIfAbsent(game, () => [])
            .add(PokemonCaughtEntry(pokemonNames[i], state.caughtAt));
      }
      final caughtAt = state.caughtAt;
      if (caughtAt == null) continue;
      recentCaught.add(PokemonCaughtEntry(pokemonNames[i], caughtAt));
    }

    final caughtGames =
        caughtByGame.entries
            .map((entry) => GameCatchStat(entry.key, entry.value))
            .toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            return byCount != 0 ? byCount : a.game.compareTo(b.game);
          });

    for (final entries in caughtEntriesByGame.values) {
      entries.sort((a, b) {
        final left = a.caughtAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.caughtAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
    }

    recentCaught.sort((a, b) => b.caughtAt!.compareTo(a.caughtAt!));

    return StatsSummary(
      totalPokemon: pokemonCount,
      caughtPokemon: caughtCount,
      totalCounts: totalCounts,
      dailyTotals: buildDailyTotals(states, range),
      caughtGames: caughtGames,
      caughtByGame: caughtEntriesByGame,
      recentCaught: recentCaught,
    );
  }

  List<StatsDailyCount> buildDailyTotals(
    List<CounterState> states,
    DateTimeRange range,
  ) {
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    final totals = <DateTime, int>{};
    final days = end.difference(start).inDays;
    for (var i = 0; i <= days; i++) {
      final day = start.add(Duration(days: i));
      totals[day] = 0;
    }
    for (final state in states) {
      if (state.dailyCounts.isEmpty) continue;
      for (final entry in state.dailyCounts.entries) {
        final parsed = DateTime.tryParse(entry.key);
        if (parsed == null) continue;
        final day = DateTime(parsed.year, parsed.month, parsed.day);
        if (day.isBefore(start) || day.isAfter(end)) continue;
        totals.update(day, (value) => value + entry.value, ifAbsent: () => 0);
      }
    }
    final sortedDays = totals.keys.toList()..sort();
    return [
      for (final day in sortedDays)
        StatsDailyCount(date: day, count: totals[day] ?? 0),
    ];
  }
}
