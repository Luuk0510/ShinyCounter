import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class LoadCaughtUseCase {
  LoadCaughtUseCase(this._repository);

  final PokemonRepository _repository;

  Future<Set<String>> call(List<Pokemon> allPokemon) =>
      _repository.loadCaught(allPokemon);
}
