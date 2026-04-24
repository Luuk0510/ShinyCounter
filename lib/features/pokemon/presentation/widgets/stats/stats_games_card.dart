import 'package:flutter/material.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_list_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';

class StatsGamesCard extends StatelessWidget {
  const StatsGamesCard({
    super.key,
    required this.label,
    required this.games,
    required this.caughtByGame,
    required this.parentController,
  });

  final String label;
  final List<GameCatchStat> games;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;
  final ScrollController parentController;

  @override
  Widget build(BuildContext context) {
    return StatsExpandableListCard<GameCatchStat>(
      title: label,
      items: games,
      parentController: parentController,
      itemBuilder: (context, game) => _StatsGamesRow(
        game: game,
        items: caughtByGame[game.game] ?? const [],
      ),
    );
  }
}

class _StatsGamesRow extends StatelessWidget {
  const _StatsGamesRow({required this.game, required this.items});

  final GameCatchStat game;
  final List<PokemonCaughtEntry> items;

  @override
  Widget build(BuildContext context) {
    return StatsRow(
      leading: GameLogo(game: game.game, size: AppSizes.statsPokemonImage),
      title: game.game,
      trailing: '${game.count}',
      trailingWidth: AppSizes.statsGameCountWidth,
      maxWidth: AppSizes.statsCaughtGameTableMaxWidth,
      onTap: items.isEmpty
          ? null
          : () => context.goToStatsGame(
              PokemonGameStatsArgs(game: game.game, items: items),
            ),
    );
  }
}
