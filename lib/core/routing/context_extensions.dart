import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/pokemon/domain/entities/pokemon.dart';
import 'app_router.dart';

extension PokemonRoutes on BuildContext {
  Future<T?> goToPokemon<T>(Pokemon pokemon) {
    return push<T>(AppRoutes.pokemonDetail, extra: pokemon);
  }

  void replaceWithPokemon(Pokemon pokemon) {
    pushReplacement(AppRoutes.pokemonDetail, extra: pokemon);
  }
}
