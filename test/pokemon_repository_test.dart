import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/features/pokemon/data/repositories/prefs_pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads custom pokemon', () async {
    final repo = PrefsPokemonRepository();
    final entries = [
      const Pokemon(
        id: 'p-pika',
        name: 'Pikachu',
        imagePath: 'assets/icon/pokeball_icon.png',
      ),
      const Pokemon(
        id: 'p-mewtwo',
        name: 'Mewtwo',
        imagePath: 'assets/icon/pokeball_icon.png',
      ),
    ];

    await repo.saveCustomPokemon(entries);
    final loaded = await repo.loadCustomPokemon();

    expect(loaded.length, entries.length);
    expect(loaded.first.name, 'Pikachu');
    expect(loaded.last.name, 'Mewtwo');
  });

  test('loadCaught reads flags per pokemon', () async {
    SharedPreferences.setMockInitialValues({
      'caught_p-pika': true,
      'caught_p-mewtwo': false,
    });
    final repo = PrefsPokemonRepository();
    final all = [
      const Pokemon(
        id: 'p-pika',
        name: 'Pikachu',
        imagePath: 'assets/icon/pokeball_icon.png',
      ),
      const Pokemon(
        id: 'p-mewtwo',
        name: 'Mewtwo',
        imagePath: 'assets/icon/pokeball_icon.png',
      ),
    ];

    final caught = await repo.loadCaught(all);

    expect(caught.contains('p-pika'), isTrue);
    expect(caught.contains('p-mewtwo'), isFalse);
  });
}
