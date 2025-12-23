import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_detail_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_game_stats_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_list_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_stats_page.dart';

class AppRoutes {
  static const home = '/';
  static const pokemonDetail = '/pokemon';
  static const stats = '/stats';
  static const statsGame = '/stats/game';
}

class AppRouter {
  AppRouter._()
    : router = GoRouter(
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
                return const _RouteErrorPage(
                  message: 'Geen Pokémon meegegeven',
                );
              }
              return PokemonDetailPage(pokemon: extra);
            },
          ),
          GoRoute(
            path: AppRoutes.stats,
            builder: (context, state) => const PokemonStatsPage(),
          ),
          GoRoute(
            path: AppRoutes.statsGame,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is! PokemonGameStatsArgs) {
                return const _RouteErrorPage(message: 'Geen game meegegeven');
              }
              return PokemonGameStatsPage(args: extra);
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
    return Scaffold(body: Center(child: Text(message)));
  }
}
