import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_counts_chart.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_resets_pie_chart.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

class StatsMetricCard extends StatelessWidget {
  const StatsMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      title: label,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
        ),
      ),
    );
  }
}

class StatsCountsChartCard extends StatelessWidget {
  const StatsCountsChartCard({
    super.key,
    required this.label,
    required this.rangeLabel,
    required this.onPickRange,
    required this.onResetRange,
    required this.counts,
  });

  final String label;
  final String rangeLabel;
  final VoidCallback onPickRange;
  final VoidCallback onResetRange;
  final List<StatsDailyCount> counts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StatsCard(
      title: label,
      titleSpacing: AppSpacing.xs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow =
                  constraints.maxWidth < AppSizes.statsRangeStackWidth;
              final buttonStyle = TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 0,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
              final dateButton = TextButton.icon(
                onPressed: onPickRange,
                style: buttonStyle,
                icon: Icon(Icons.date_range, color: colors.onSurfaceVariant),
                label: Text(
                  rangeLabel,
                  style: AppTypography.listTitle.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.statsRangeTextSize,
                  ),
                ),
              );
              final resetButton = TextButton(
                onPressed: onResetRange,
                style: buttonStyle,
                child: Text(
                  context.l10n.statsRangeReset,
                  style: AppTypography.listTitle.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.statsRangeTextSize,
                  ),
                ),
              );
              final controls = isNarrow
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        dateButton,
                        const SizedBox(height: AppSizes.statsRangeStackGap),
                        resetButton,
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        dateButton,
                        const SizedBox(width: AppSpacing.sm),
                        resetButton,
                      ],
                    );
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  controls,
                  const SizedBox(height: AppSpacing.sm),
                  StatsCountsChart(
                    counts: counts,
                    height: isNarrow
                        ? AppSizes.statsChartHeightCompact
                        : AppSizes.statsChartHeight,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

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
    final colors = Theme.of(context).colorScheme;
    return StatsCard(
      title: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: StatsExpandableSection(
              itemCount: games.length,
              foregroundColor: colors.onSurfaceVariant,
              parentController: parentController,
              builder: (visibleCount) {
                final visibleGames = games.take(visibleCount).toList();
                return _StatsGamesTable(
                  games: visibleGames,
                  caughtByGame: caughtByGame,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatsRecentCard extends StatelessWidget {
  const StatsRecentCard({
    super.key,
    required this.label,
    required this.items,
    required this.parentController,
  });

  final String label;
  final List<PokemonCaughtEntry> items;
  final ScrollController parentController;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StatsCard(
      title: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: StatsExpandableSection(
              itemCount: items.length,
              foregroundColor: colors.onSurfaceVariant,
              parentController: parentController,
              builder: (visibleCount) {
                final visibleItems = items.take(visibleCount).toList();
                return _StatsRecentTable(items: visibleItems);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatsResetsCard extends StatelessWidget {
  const StatsResetsCard({super.key, required this.label, required this.resets});

  final String label;
  final List<GameResetStat> resets;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      title: label,
      child: StatsResetsPieChart(resets: resets),
    );
  }
}

class StatsPokemonResetsCard extends StatelessWidget {
  const StatsPokemonResetsCard({
    super.key,
    required this.label,
    required this.items,
    required this.parentController,
  });

  final String label;
  final List<PokemonResetStat> items;
  final ScrollController parentController;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StatsCard(
      title: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: StatsExpandableSection(
              itemCount: items.length,
              foregroundColor: colors.onSurfaceVariant,
              parentController: parentController,
              builder: (visibleCount) {
                final visibleItems = items.take(visibleCount).toList();
                return _StatsPokemonResetsTable(items: visibleItems);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGamesTable extends StatelessWidget {
  const _StatsGamesTable({required this.games, required this.caughtByGame});

  final List<GameCatchStat> games;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final game in games)
          _StatsGamesRow(
            game: game,
            items: caughtByGame[game.game] ?? const [],
          ),
      ],
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

class _StatsRecentTable extends StatelessWidget {
  const _StatsRecentTable({required this.items});

  final List<PokemonCaughtEntry> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final item in items) _StatsRecentRow(item: item)],
    );
  }
}

class _StatsPokemonResetsTable extends StatelessWidget {
  const _StatsPokemonResetsTable({required this.items});

  final List<PokemonResetStat> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final item in items) _StatsPokemonResetsRow(item: item)],
    );
  }
}

class _StatsRecentRow extends StatelessWidget {
  const _StatsRecentRow({required this.item});

  final PokemonCaughtEntry item;

  @override
  Widget build(BuildContext context) {
    return StatsRow(
      leading: PokemonImage(
        path: item.pokemon.imagePath,
        isLocalFile: item.pokemon.isLocalFile,
        width: AppSizes.statsPokemonImage,
        height: AppSizes.statsPokemonImage,
      ),
      title: item.pokemon.name,
      trailing: formatDate(item.caughtAt),
      trailingWidth: AppSizes.statsDateWidth,
      maxWidth: AppSizes.statsRecentCatchTableMaxWidth,
      stackOnNarrow: true,
      onTap: () => context.goToPokemon(item.pokemon),
    );
  }
}

class _StatsPokemonResetsRow extends StatelessWidget {
  const _StatsPokemonResetsRow({required this.item});

  final PokemonResetStat item;

  @override
  Widget build(BuildContext context) {
    return StatsRow(
      leading: PokemonImage(
        path: item.pokemon.imagePath,
        isLocalFile: item.pokemon.isLocalFile,
        width: AppSizes.statsPokemonImage,
        height: AppSizes.statsPokemonImage,
      ),
      title: item.pokemon.name,
      trailing: '${item.count}',
      trailingWidth: AppSizes.statsGameCountWidth,
      maxWidth: AppSizes.statsResetsPokemonTableMaxWidth,
      stackOnNarrow: true,
      onTap: () => context.goToPokemon(item.pokemon),
    );
  }
}
