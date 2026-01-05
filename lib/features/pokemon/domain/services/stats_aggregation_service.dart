import 'package:flutter/material.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';

class StatsSnapshot {
  const StatsSnapshot({required this.summary, required this.states});

  final StatsSummary summary;
  final List<CounterState> states;
}

class StatsAggregationService {
  StatsAggregationService({required StatsRepository repository})
    : _repository = repository;

  final StatsRepository _repository;

  Future<StatsSnapshot> loadStats(DateTimeRange range) async {
    final source = await _repository.loadStatsSource();
    final summary = _buildSummary(
      pokemonCount: source.pokemon.length,
      caughtCount: source.caught.length,
      states: source.states,
      range: range,
      pokemonNames: source.pokemon,
    );

    return StatsSnapshot(summary: summary, states: source.states);
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
    final resetTotalsByGame = <String, int>{};
    final resetTotalsByPokemon = <PokemonResetStat>[];

    for (var i = 0; i < states.length; i++) {
      final state = states[i];
      final game = state.caughtGame;
      if (game != null && game.isNotEmpty && state.count > 0) {
        resetTotalsByGame.update(
          game,
          (value) => value + state.count,
          ifAbsent: () => state.count,
        );
      }
      if (state.count > 0) {
        resetTotalsByPokemon.add(
          PokemonResetStat(pokemonNames[i], state.count),
        );
      }
      if (!state.isCaught) continue;
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

    final resetsByGame =
        resetTotalsByGame.entries
            .map((entry) => GameResetStat(entry.key, entry.value))
            .toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            return byCount != 0 ? byCount : a.game.compareTo(b.game);
          });
    resetTotalsByPokemon.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.pokemon.name.compareTo(b.pokemon.name);
    });

    return StatsSummary(
      totalPokemon: pokemonCount,
      caughtPokemon: caughtCount,
      totalCounts: totalCounts,
      dailyTotals: buildDailyTotals(states, range),
      caughtGames: caughtGames,
      caughtByGame: caughtEntriesByGame,
      recentCaught: recentCaught,
      resetsByGame: resetsByGame,
      resetsByPokemon: resetTotalsByPokemon,
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
