import 'package:flutter/material.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_list_card.dart';
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
    return StatsExpandableListCard<PokemonCaughtEntry>(
      title: label,
      items: items,
      parentController: parentController,
      itemBuilder: (context, item) => _StatsRecentRow(item: item),
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
