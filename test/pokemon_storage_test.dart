import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/pokemon_storage.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

class _MemoryStore implements KeyValueStore {
  final Map<String, String> _strings = {};
  final Map<String, int> _ints = {};
  final Map<String, bool> _bools = {};

  @override
  Future<void> reload() async {}

  @override
  Future<void> remove(String key) async {
    _strings.remove(key);
    _ints.remove(key);
    _bools.remove(key);
  }

  @override
  Future<bool?> getBool(String key) async => _bools[key];

  @override
  Future<int?> getInt(String key) async => _ints[key];

  @override
  Future<String?> getString(String key) async => _strings[key];

  @override
  Future<void> setBool(String key, bool value) async {
    _bools[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _ints[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _strings[key] = value;
  }
}

void main() {
  group('PokemonStorage', () {
    late _MemoryStore store;
    late PokemonStorage storage;

    setUp(() {
      store = _MemoryStore();
      storage = PokemonStorage(store: store);
    });

    test('saves and loads custom pokemon with edits', () async {
      final initial = [
        const Pokemon(id: 'custom_1', name: 'Foo', imagePath: 'path/foo.png'),
      ];
      await storage.saveCustomPokemon(initial);

      var loaded = await storage.loadCustomPokemon();
      expect(loaded.single.name, 'Foo');

      final updated = [
        const Pokemon(id: 'custom_1', name: 'Bar', imagePath: 'path/foo.png'),
      ];
      await storage.saveCustomPokemon(updated);
      loaded = await storage.loadCustomPokemon();
      expect(loaded.single.name, 'Bar');

      await storage.saveCustomPokemon([]);
      loaded = await storage.loadCustomPokemon();
      expect(loaded, isEmpty);
    });

    test('loadCustomPokemon builds legacy id when missing', () async {
      final legacy = [
        {'name': 'LegacyMon', 'imagePath': 'path/legacy.png'}
      ];
      await store.setString('custom_pokemon', jsonEncode(legacy));

      final loaded = await storage.loadCustomPokemon();
      expect(loaded.single.id, 'legacy_legacymon');
      expect(loaded.single.name, 'LegacyMon');
    });

    test('loadCaught returns caught ids from store', () async {
      final mons = [
        const Pokemon(id: '001', name: 'Bulbasaur', imagePath: '001.png'),
        const Pokemon(id: '002', name: 'Ivysaur', imagePath: '002.png'),
      ];
      await store.setBool('caught_001', true);
      await store.setBool('caught_002', false);

      final caught = await storage.loadCaught(mons);

      expect(caught, contains('001'));
      expect(caught, isNot(contains('002')));
    });
  });
}
