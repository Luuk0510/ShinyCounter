import 'package:shiny_counter/features/pokemon/domain/entities/stats_models.dart';

export 'package:shiny_counter/features/pokemon/domain/entities/stats_models.dart';

class PokemonGameStatsArgs {
  const PokemonGameStatsArgs({required this.game, required this.items});

  final String game;
  final List<PokemonCaughtEntry> items;
}
