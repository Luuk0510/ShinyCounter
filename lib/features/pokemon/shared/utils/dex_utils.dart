import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

int? dexFromString(String value) {
  final match = RegExp(r'(\d{4})').firstMatch(value);
  if (match == null) return null;
  return int.tryParse(match.group(1) ?? '');
}

int dexValueFromPokemon(Pokemon pokemon) {
  final fromPath = dexFromString(pokemon.imagePath);
  if (fromPath != null) return fromPath;

  final fromId = dexFromString(pokemon.id);
  if (fromId != null) return fromId;

  return 1 << 30;
}

int pokemonDexComparator(Pokemon a, Pokemon b) {
  final da = dexValueFromPokemon(a);
  final db = dexValueFromPokemon(b);
  if (da != db) return da.compareTo(db);
  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
}
