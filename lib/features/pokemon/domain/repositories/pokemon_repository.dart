import '../entities/pokemon.dart';

abstract class PokemonRepository {
  Future<List<Pokemon>> loadCustomPokemon();
  Future<void> saveCustomPokemon(List<Pokemon> custom);
  Future<Set<String>> loadCaught(List<Pokemon> allPokemon);
}
