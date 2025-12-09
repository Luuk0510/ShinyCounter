import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

/// Extracts the first 1–4 digit number found in a string, if any.
int? dexFromString(String value) {
  final match = RegExp(r'(\d{1,4})').firstMatch(value);
  if (match == null) return null;
  return int.tryParse(match.group(1) ?? '');
}

/// Returns the best-effort dex number for a Pokemon from id or path.
int? dexNumberFromPokemon(Pokemon pokemon) {
  final customMatch = RegExp(r'^custom_(\d{1,4})_').firstMatch(pokemon.id);
  if (customMatch != null) {
    return int.tryParse(customMatch.group(1) ?? '');
  }

  final fromPath = dexFromString(pokemon.imagePath);
  if (fromPath != null) return fromPath;

  final fromId = dexFromString(pokemon.id);
  if (fromId != null) return fromId;

  return null;
}

/// Padded dex string (e.g., 1 -> "0001") or empty when unknown.
String pokemonDexString(Pokemon pokemon) {
  final dex = dexNumberFromPokemon(pokemon);
  if (dex == null) return '';
  return dex.toString().padLeft(4, '0');
}

/// Human label with prefix (e.g., "#0001") or "Custom" when unknown.
String pokemonDexLabel(Pokemon pokemon) {
  final padded = pokemonDexString(pokemon);
  if (padded.isEmpty) return 'Custom';
  return '#$padded';
}

/// Generation ranges (start, end inclusive).
const Map<int, (int, int)> genRanges = {
  1: (1, 151),
  2: (152, 251),
  3: (252, 386),
  4: (387, 493),
  5: (494, 649),
  6: (650, 721),
  7: (722, 809),
  8: (810, 905),
  9: (906, 1025),
};

/// Returns true if the dex number is within the given generation.
bool isDexInGen(int dex, int? gen) {
  if (gen == null) return true;
  final range = genRanges[gen];
  if (range == null) return true;
  return dex >= range.$1 && dex <= range.$2;
}

int dexValueFromPokemon(Pokemon pokemon) {
  final fromNumber = dexNumberFromPokemon(pokemon);
  if (fromNumber != null) return fromNumber;
  // Large fallback so unknowns sort last.
  return 1 << 30;
}

int pokemonDexComparator(Pokemon a, Pokemon b) {
  final da = dexValueFromPokemon(a);
  final db = dexValueFromPokemon(b);
  if (da != db) return da.compareTo(db);
  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
}
