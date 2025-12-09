import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';

void main() {
  group('dex utils', () {
    const bulba = Pokemon(
      id: '001',
      name: 'Bulbasaur',
      imagePath: 'assets/0001_base_std_none_mf_s.png',
    );
    const charizard = Pokemon(
      id: '006',
      name: 'Charizard',
      imagePath: 'assets/0006_base_std_none_mf_s.png',
    );
    const custom = Pokemon(
      id: 'custom_123',
      name: 'Custom',
      imagePath: 'assets/custom.png',
    );

    test('dexFromString extracts four-digit number', () {
      expect(dexFromString('abc0007_def'), 7);
      expect(dexFromString('no dex here'), isNull);
    });

    test('dexNumberFromPokemon parses custom id and pads label', () {
      const giratina = Pokemon(
        id: 'custom_0487_12345',
        name: 'Giratina',
        imagePath: 'assets/custom.png',
      );
      expect(dexNumberFromPokemon(giratina), 487);
      expect(pokemonDexString(giratina), '0487');
      expect(pokemonDexLabel(giratina), '#0487');
    });

    test('pokemonDexLabel falls back to Custom when no digits found', () {
      const unknown = Pokemon(
        id: 'no_digits',
        name: 'MissingNo',
        imagePath: 'assets/unknown.png',
      );
      expect(pokemonDexLabel(unknown), 'Custom');
      expect(pokemonDexString(unknown), isEmpty);
    });

    test('isDexInGen respects configured ranges', () {
      expect(isDexInGen(1, 1), isTrue);
      expect(isDexInGen(152, 1), isFalse);
      expect(isDexInGen(905, 8), isTrue);
      expect(isDexInGen(906, 8), isFalse);
      expect(isDexInGen(906, 9), isTrue);
      expect(isDexInGen(25, null), isTrue); // null = all
    });

    test('dexValueFromPokemon prefers imagePath then id', () {
      expect(dexValueFromPokemon(bulba), 1);
      expect(dexValueFromPokemon(charizard), 6);
      expect(dexValueFromPokemon(custom), greaterThan(1000));
    });

    test('pokemonDexComparator sorts by dex then name', () {
      final sorted = [charizard, custom, bulba]..sort(pokemonDexComparator);
      expect(sorted.first, bulba);
      expect(sorted[1], charizard);
      expect(sorted.last, custom);
    });
  });
}
