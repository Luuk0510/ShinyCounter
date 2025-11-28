import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'pokemon.dart';

class PokemonStorage {
  PokemonStorage() : _prefs = SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefs;

  Future<List<Pokemon>> loadCustomPokemon() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_customKey);
    if (raw == null) return [];

    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map(
          (e) => Pokemon(
            name: e['name'] as String,
            imagePath: e['imagePath'] as String,
            isLocalFile: e['isLocalFile'] as bool? ?? false,
          ),
        )
        .toList();
  }

  Future<void> saveCustomPokemon(List<Pokemon> custom) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(
      custom
          .map(
            (p) => {
              'name': p.name,
              'imagePath': p.imagePath,
              'isLocalFile': p.isLocalFile,
            },
          )
          .toList(),
    );
    await prefs.setString(_customKey, encoded);
  }

  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) async {
    final prefs = await _prefs;
    final caught = <String>{};
    for (final p in allPokemon) {
      if (prefs.getBool(_caughtKey(p.name)) ?? false) {
        caught.add(p.name);
      }
    }
    return caught;
  }

  String _caughtKey(String name) => 'caught_${name.toLowerCase()}';
  static const _customKey = 'custom_pokemon';
}
