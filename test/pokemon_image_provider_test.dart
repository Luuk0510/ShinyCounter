import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image_provider.dart';

void main() {
  test('returns FileImage for local file paths', () {
    final provider = pokemonImageProvider(
      'C:/tmp/pokemon.png',
      isLocalFile: true,
    );
    expect(provider, isA<FileImage>());
  });

  test('returns AssetImage for asset paths even if local', () {
    final provider = pokemonImageProvider(
      'assets/pokemons/0001.png',
      isLocalFile: true,
    );
    expect(provider, isA<AssetImage>());
  });

  test('returns AssetImage when not local', () {
    final provider = pokemonImageProvider(
      'assets/pokemons/0001.png',
      isLocalFile: false,
    );
    expect(provider, isA<AssetImage>());
  });
}
