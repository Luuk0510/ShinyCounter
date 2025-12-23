import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
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
      appBar: AppBar(
        title: Text(args.game),
        centerTitle: true,
        toolbarHeight: AppSizes.toolbarHeight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppRadii.lg),
          ),
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
                return Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.statsRecentCatchTableMaxWidth,
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => context.goToPokemon(entry.pokemon),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                            horizontal: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              PokemonImage(
                                path: entry.pokemon.imagePath,
                                isLocalFile: entry.pokemon.isLocalFile,
                                width: AppSizes.statsPokemonImage,
                                height: AppSizes.statsPokemonImage,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  entry.pokemon.name,
                                  style: AppTypography.listTitle.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              SizedBox(
                                width: AppSizes.statsDateWidth,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    formatDate(entry.caughtAt),
                                    style: AppTypography.listTitle.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
