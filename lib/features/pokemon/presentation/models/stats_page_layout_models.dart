import 'package:flutter/widgets.dart';

enum StatsCardId {
  caught,
  total,
  games,
  recent,
  resetsPokemon,
  resetsGame,
  history,
}

class StatsCardEntry {
  const StatsCardEntry({
    required this.id,
    required this.label,
    required this.widget,
    required this.span,
  });

  final StatsCardId id;
  final String label;
  final Widget widget;
  final int span;
}
