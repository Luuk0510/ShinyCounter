import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

class PokemonCaughtEntry {
  const PokemonCaughtEntry(this.pokemon, this.caughtAt);

  final Pokemon pokemon;
  final DateTime? caughtAt;
}

class PokemonGameStatsArgs {
  const PokemonGameStatsArgs({required this.game, required this.items});

  final String game;
  final List<PokemonCaughtEntry> items;
}
