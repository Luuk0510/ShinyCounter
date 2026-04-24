import 'package:flutter/material.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

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
      child: Align(
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
