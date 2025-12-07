import 'dart:convert';

import 'package:shiny_counter/core/storage/key_value_store.dart';

import '../../domain/entities/pokemon.dart';

class PokemonStorage {
  PokemonStorage({KeyValueStore? store}) : _store = store ?? SharedPrefsStore();

  final KeyValueStore _store;

  Future<List<Pokemon>> loadCustomPokemon() async {
    final raw = await _store.getString(_customKey);
    if (raw == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map(
            (e) => Pokemon(
              id:
                  (e['id'] as String?) ??
                  'legacy_${(e['name'] as String).toLowerCase()}',
              name: e['name'] as String,
              imagePath: e['imagePath'] as String,
              isLocalFile: e['isLocalFile'] as bool? ?? false,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomPokemon(List<Pokemon> custom) async {
    final encoded = jsonEncode(
      custom
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'imagePath': p.imagePath,
              'isLocalFile': p.isLocalFile,
            },
          )
          .toList(),
    );
    await _store.setString(_customKey, encoded);
  }

  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) async {
    final caught = <String>{};
    for (final p in allPokemon) {
      if (await _store.getBool(_caughtKey(p.id)) ?? false) {
        caught.add(p.id);
      }
    }
    return caught;
  }

  String _caughtKey(String id) => 'caught_${id.toLowerCase()}';
  static const _customKey = 'custom_pokemon';
}
