import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_storage.dart';

class PrefsPokemonRepository implements PokemonRepository {
  PrefsPokemonRepository({PokemonStorage? storage}) : _storage = storage ?? PokemonStorage();

  final PokemonStorage _storage;

  @override
  Future<List<Pokemon>> loadCustomPokemon() => _storage.loadCustomPokemon();

  @override
  Future<void> saveCustomPokemon(List<Pokemon> custom) => _storage.saveCustomPokemon(custom);

  @override
  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) => _storage.loadCaught(allPokemon);
}
