import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class LoadCustomPokemonUseCase {
  LoadCustomPokemonUseCase(this._repository);

  final PokemonRepository _repository;

  Future<List<Pokemon>> call() => _repository.loadCustomPokemon();
}
