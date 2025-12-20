import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';

class _FakePokemonRepository implements PokemonRepository {
  List<Pokemon> saved = [];

  @override
  Future<List<Pokemon>> loadCustomPokemon() async => saved;

  @override
  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) async => {};

  @override
  Future<void> saveCustomPokemon(List<Pokemon> custom) async {
    saved = List<Pokemon>.from(custom);
  }
}

void main() {
  test('save custom pokemon forwards list to repository', () async {
    final repo = _FakePokemonRepository();
    final useCase = SaveCustomPokemonUseCase(repo);
    const list = [
      Pokemon(id: 'custom_0001_1', name: 'Bulbasaur', imagePath: 'a.png'),
      Pokemon(id: 'custom_0002_2', name: 'Ivysaur', imagePath: 'b.png'),
    ];

    await useCase(list);
    expect(repo.saved, list);
  });
}
