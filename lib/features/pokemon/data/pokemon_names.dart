import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class PokemonNames {
  PokemonNames(this._names);

  final Map<String, String> _names;

  String nameFor(String dex) => _names[dex] ?? 'Pokémon #$dex';

  static Future<PokemonNames> load() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/pokemon_names_en.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final map = <String, String>{};
      decoded.forEach((key, value) {
        map[key.padLeft(4, '0')] = value.toString();
      });
      return PokemonNames(map);
    } catch (_) {
      return PokemonNames({});
    }
  }
}
