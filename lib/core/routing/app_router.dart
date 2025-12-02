import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_detail_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_list_page.dart';

class AppRoutes {
  static const home = '/';
  static const pokemonDetail = '/pokemon';
}

class AppRouter {
  AppRouter._() : router = GoRouter(
          initialLocation: AppRoutes.home,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const PokemonListPage(),
            ),
            GoRoute(
              path: AppRoutes.pokemonDetail,
              builder: (context, state) {
                final extra = state.extra;
                if (extra is! Pokemon) {
                  return const _RouteErrorPage(message: 'Geen Pokémon meegegeven');
                }
                return PokemonDetailPage(pokemon: extra);
              },
            ),
          ],
        );

  static final AppRouter instance = AppRouter._();

  final GoRouter router;
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }
}
