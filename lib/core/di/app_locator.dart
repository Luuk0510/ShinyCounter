import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/data/repositories/pokemon_stats_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/pokemon_storage.dart';

class AppLocator {
  AppLocator._();

  static final AppLocator instance = AppLocator._();

  late final PokemonRepository pokemonRepository;
  late final StatsRepository statsRepository;
  late final CounterSync counterSyncService;
  late final SpriteService spriteService;
  late final KeyValueStore prefsStore;

  Future<void> init() async {
    prefsStore = SharedPrefsStore();
    pokemonRepository = PokemonStorage(store: prefsStore);
    counterSyncService = CounterSyncService(store: prefsStore);
    statsRepository = PokemonStatsRepository(
      pokemonRepository: pokemonRepository,
      counterSync: counterSyncService,
    );
    spriteService = PokemonSpriteService();
  }
}
