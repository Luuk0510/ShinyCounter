import 'package:flutter/widgets.dart';

enum PokemonStatsCardId {
  caught,
  total,
  games,
  recent,
  resetsPokemon,
  resetsGame,
  history,
}

class PokemonStatsCardEntry {
  const PokemonStatsCardEntry({
    required this.id,
    required this.label,
    required this.widget,
    required this.span,
  });

  final PokemonStatsCardId id;
  final String label;
  final Widget widget;
  final int span;
}
