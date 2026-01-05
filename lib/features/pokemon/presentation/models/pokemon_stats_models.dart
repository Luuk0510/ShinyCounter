import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

class PokemonCaughtEntry {
  const PokemonCaughtEntry(this.pokemon, this.caughtAt);

  final Pokemon pokemon;
  final DateTime? caughtAt;
}

class PokemonResetStat {
  const PokemonResetStat(this.pokemon, this.count);

  final Pokemon pokemon;
  final int count;
}

class PokemonGameStatsArgs {
  const PokemonGameStatsArgs({required this.game, required this.items});

  final String game;
  final List<PokemonCaughtEntry> items;
}

class StatsDailyCount {
  const StatsDailyCount({required this.date, required this.count});

  final DateTime date;
  final int count;
}

class GameCatchStat {
  const GameCatchStat(this.game, this.count);

  final String game;
  final int count;
}

class GameResetStat {
  const GameResetStat(this.game, this.count);

  final String game;
  final int count;
}

class StatsSummary {
  const StatsSummary({
    required this.totalPokemon,
    required this.caughtPokemon,
    required this.totalCounts,
    required this.dailyTotals,
    required this.caughtGames,
    required this.caughtByGame,
    required this.recentCaught,
    required this.resetsByGame,
    required this.resetsByPokemon,
  });

  const StatsSummary.empty()
    : totalPokemon = 0,
      caughtPokemon = 0,
      totalCounts = 0,
      dailyTotals = const <StatsDailyCount>[],
      caughtGames = const <GameCatchStat>[],
      caughtByGame = const <String, List<PokemonCaughtEntry>>{},
      recentCaught = const <PokemonCaughtEntry>[],
      resetsByGame = const <GameResetStat>[],
      resetsByPokemon = const <PokemonResetStat>[];

  final int totalPokemon;
  final int caughtPokemon;
  final int totalCounts;
  final List<StatsDailyCount> dailyTotals;
  final List<GameCatchStat> caughtGames;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;
  final List<PokemonCaughtEntry> recentCaught;
  final List<GameResetStat> resetsByGame;
  final List<PokemonResetStat> resetsByPokemon;

  StatsSummary copyWith({
    int? totalPokemon,
    int? caughtPokemon,
    int? totalCounts,
    List<StatsDailyCount>? dailyTotals,
    List<GameCatchStat>? caughtGames,
    Map<String, List<PokemonCaughtEntry>>? caughtByGame,
    List<PokemonCaughtEntry>? recentCaught,
    List<GameResetStat>? resetsByGame,
    List<PokemonResetStat>? resetsByPokemon,
  }) {
    return StatsSummary(
      totalPokemon: totalPokemon ?? this.totalPokemon,
      caughtPokemon: caughtPokemon ?? this.caughtPokemon,
      totalCounts: totalCounts ?? this.totalCounts,
      dailyTotals: dailyTotals ?? this.dailyTotals,
      caughtGames: caughtGames ?? this.caughtGames,
      caughtByGame: caughtByGame ?? this.caughtByGame,
      recentCaught: recentCaught ?? this.recentCaught,
      resetsByGame: resetsByGame ?? this.resetsByGame,
      resetsByPokemon: resetsByPokemon ?? this.resetsByPokemon,
    );
  }
}
