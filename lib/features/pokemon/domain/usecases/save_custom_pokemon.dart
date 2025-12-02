import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class SaveCustomPokemonUseCase {
  SaveCustomPokemonUseCase(this._repository);

  final PokemonRepository _repository;

  Future<void> call(List<Pokemon> custom) => _repository.saveCustomPokemon(custom);
}
