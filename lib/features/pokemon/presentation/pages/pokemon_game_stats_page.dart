import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_app_bar.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

class PokemonCaughtEntry {
  const PokemonCaughtEntry(this.pokemon, this.caughtAt);

  final Pokemon pokemon;
  final DateTime? caughtAt;
}

class PokemonGameStatsArgs {
  const PokemonGameStatsArgs({required this.game, required this.items});

  final String game;
  final List<PokemonCaughtEntry> items;
}

class PokemonGameStatsPage extends StatelessWidget {
  const PokemonGameStatsPage({super.key, required this.args});

  final PokemonGameStatsArgs args;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final items = args.items;

    return Scaffold(
      appBar: StatsAppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameLogo(game: args.game, size: AppSizes.appBarTitleIcon),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.huntGame(args.game),
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                l10n.noCounts,
                style: AppTypography.listTitle.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              itemCount: items.length,
              separatorBuilder: (_, index) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final entry = items[index];
                return Material(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: StatsRow(
                    leading: PokemonImage(
                      path: entry.pokemon.imagePath,
                      isLocalFile: entry.pokemon.isLocalFile,
                      width: AppSizes.statsPokemonImage,
                      height: AppSizes.statsPokemonImage,
                    ),
                    title: entry.pokemon.name,
                    trailing: formatDate(entry.caughtAt),
                    trailingWidth: AppSizes.statsDateWidth,
                    maxWidth: AppSizes.statsRecentCatchTableMaxWidth,
                    onTap: () => context.goToPokemon(entry.pokemon),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.sm,
                    ),
                    borderRadius: AppRadii.md,
                    useMaterial: false,
                    titleStyle: AppTypography.listTitle.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    trailingStyle: AppTypography.listTitle.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
