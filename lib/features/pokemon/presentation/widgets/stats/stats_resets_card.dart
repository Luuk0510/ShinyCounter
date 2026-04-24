import 'package:flutter/material.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_resets_pie_chart.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';

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
      child: Align(
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
