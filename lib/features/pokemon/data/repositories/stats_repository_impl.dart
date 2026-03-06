import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl({
    required PokemonRepository pokemonRepository,
    required CounterSync counterSync,
  }) : _pokemonRepository = pokemonRepository,
       _counterSync = counterSync;

  final PokemonRepository _pokemonRepository;
  final CounterSync _counterSync;

  @override
  Future<StatsSourceData> loadStatsSource() async {
    final pokemon = await _pokemonRepository.loadCustomPokemon();
    final caught = await _pokemonRepository.loadCaught(pokemon);
    final states = await _counterSync.loadStates(
      pokemon.map((p) => CounterKeys.fromId(p.id).counter),
    );
    return StatsSourceData(pokemon: pokemon, caught: caught, states: states);
  }
}
