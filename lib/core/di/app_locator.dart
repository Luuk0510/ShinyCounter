import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/data/repositories/prefs_pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';

class AppLocator {
  AppLocator._();

  static final AppLocator instance = AppLocator._();

  late final PokemonRepository pokemonRepository;
  late final CounterSyncService counterSyncService;

  Future<void> init() async {
    pokemonRepository = PrefsPokemonRepository();
    counterSyncService = await CounterSyncService.instance();
  }
}
