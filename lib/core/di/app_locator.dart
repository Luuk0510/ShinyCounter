import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/data/repositories/prefs_pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';

class AppLocator {
  AppLocator._();

  static final AppLocator instance = AppLocator._();

  late final PokemonRepository pokemonRepository;
  late final CounterSyncService counterSyncService;
  late final LoadCustomPokemonUseCase loadCustomPokemon;
  late final SaveCustomPokemonUseCase saveCustomPokemon;
  late final LoadCaughtUseCase loadCaught;
  late final ToggleCaughtUseCase toggleCaught;
  late final SpriteService spriteRepository;

  Future<void> init() async {
    pokemonRepository = PrefsPokemonRepository();
    counterSyncService = await CounterSyncService.instance();
    loadCustomPokemon = LoadCustomPokemonUseCase(pokemonRepository);
    saveCustomPokemon = SaveCustomPokemonUseCase(pokemonRepository);
    loadCaught = LoadCaughtUseCase(pokemonRepository);
    toggleCaught = ToggleCaughtUseCase(counterSyncService);
    spriteRepository = SpriteRepository();
  }
}
