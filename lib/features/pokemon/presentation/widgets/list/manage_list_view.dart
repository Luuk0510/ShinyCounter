import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/filters/search_gen_filter_row.dart';

class ManageAction {
  const ManageAction({required this.pokemon, required this.delete});

  final Pokemon pokemon;
  final bool delete;
}

class ManagePokemonImage extends StatelessWidget {
  const ManagePokemonImage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final size = AppSpacing.xxl + AppSpacing.md;
    return PokemonImage(
      path: pokemon.imagePath,
      isLocalFile: pokemon.isLocalFile,
      width: size,
      height: size,
      fallbackIconSize: size * 0.55,
    );
  }
}

class ManageListView extends StatefulWidget {
  const ManageListView({super.key, required this.pokemonSorted});

  final List<Pokemon> pokemonSorted;

  static Key rowKey(String id) => ValueKey('manage.row.$id');
  static Key editKey(String id) => ValueKey('manage.edit.$id');
  static Key deleteKey(String id) => ValueKey('manage.delete.$id');

  @override
  State<ManageListView> createState() => _ManageListViewState();
}

class _ManageListViewState extends State<ManageListView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int? _selectedGen;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final editIconColor = _actionIconColor(colors.primary);
    final deleteIconColor = _actionIconColor(
      AppButtonPalette.deleteIcon(colors),
    );
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final filter = _query.trim().toLowerCase();
    final digitsOnly = filter.replaceAll(RegExp(r'[^0-9]'), '');
    final byGen = widget.pokemonSorted.where(_matchesGen).toList();
    final filtered = filter.isEmpty && digitsOnly.isEmpty
        ? byGen
        : byGen.where((p) {
            final dex = pokemonDexString(p);
            return p.name.toLowerCase().contains(filter) ||
                dex.contains(filter.replaceAll('#', '')) ||
                (digitsOnly.isNotEmpty && dex.contains(digitsOnly));
          }).toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: viewInsets),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.sheetHandleWidth,
                height: AppSizes.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: colors.outlineVariant.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.manageTitle,
                style: AppTypography.title.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SearchGenFilterRow(
                searchController: _searchController,
                hintText: context.l10n.searchByNameOrDex,
                query: _query,
                cancelTooltip: context.l10n.cancel,
                onQueryChanged: (value) => setState(() => _query = value),
                onClearQuery: () => setState(() {
                  _query = '';
                  _searchController.clear();
                }),
                allGensLabel: context.l10n.filterAllGens,
                selectedGen: _selectedGen,
                onGenChanged: (gen) => setState(() => _selectedGen = gen),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              color: colors.onSurfaceVariant,
                              size: AppSizes.spriteThumb,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              context.l10n.noPokemonFound,
                              style: AppTypography.button.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.tryAnotherFilter,
                              textAlign: TextAlign.center,
                              style: AppTypography.button.copyWith(
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return ListTile(
                            key: ManageListView.rowKey(p.id),
                            leading: ManagePokemonImage(pokemon: p),
                            title: Text(
                              p.name,
                              style: AppTypography.listTitle.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              pokemonDexLabel(p),
                              style: AppTypography.button.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  key: ManageListView.editKey(p.id),
                                  iconSize: AppSizes.cardActionIcon,
                                  icon: const Icon(Icons.edit),
                                  color: editIconColor,
                                  tooltip: context.l10n.manageEditTooltip,
                                  onPressed: () => Navigator.of(context).pop(
                                    ManageAction(pokemon: p, delete: false),
                                  ),
                                ),
                                IconButton(
                                  key: ManageListView.deleteKey(p.id),
                                  iconSize: AppSizes.cardActionIcon,
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: context.l10n.manageDeleteTooltip,
                                  color: deleteIconColor,
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pop(ManageAction(pokemon: p, delete: true)),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, _) =>
                            const Divider(height: AppSpacing.md),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _matchesGen(Pokemon p) {
    final gen = _selectedGen;
    if (gen == null) return true;
    final dexNum = dexNumberFromPokemon(p);
    if (dexNum == null) return true;
    return isDexInGen(dexNum, gen);
  }

  Color _actionIconColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 0.9).clamp(0.0, 1.0)).toColor();
  }
}
