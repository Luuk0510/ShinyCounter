import 'dart:convert';

import 'package:shiny_counter/core/storage/app_prefs_keys.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

import '../../domain/entities/pokemon.dart';

class PokemonStorage implements PokemonRepository {
  PokemonStorage({KeyValueStore? store}) : _store = store ?? SharedPrefsStore();

  final KeyValueStore _store;

  @override
  Future<List<Pokemon>> loadCustomPokemon() async {
    final raw = await _store.getString(AppPrefsKeys.customPokemon);
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

  @override
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
    await _store.setString(AppPrefsKeys.customPokemon, encoded);
  }

  @override
  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) async {
    final values = await _store.snapshot();
    final caught = <String>{};
    for (final p in allPokemon) {
      final caughtKey = CounterKeys.fromId(p.id).caught;
      if (values[caughtKey] as bool? ?? false) {
        caught.add(p.id);
      }
    }
    return caught;
  }
}
