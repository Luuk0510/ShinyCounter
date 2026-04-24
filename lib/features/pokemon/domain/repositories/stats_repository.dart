import 'package:shiny_counter/features/pokemon/domain/entities/counter_state.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

class StatsSourceData {
  const StatsSourceData({
    required this.pokemon,
    required this.caught,
    required this.states,
  });

  final List<Pokemon> pokemon;
  final Set<String> caught;
  final List<CounterState> states;
}

abstract class StatsRepository {
  Future<StatsSourceData> loadStatsSource();
}
