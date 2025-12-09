import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Image.asset(
        pokemon.imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stack) =>
            Icon(Icons.catching_pokemon, size: size * 0.55),
      ),
    );
  }
}

class ManageListView extends StatefulWidget {
  const ManageListView({super.key, required this.pokemonSorted});

  final List<Pokemon> pokemonSorted;

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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: context.l10n.searchByNameOrDex,
                        isDense: true,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.sm),
                          ),
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: context.l10n.cancel,
                                onPressed: () => setState(() {
                                  _query = '';
                                  _searchController.clear();
                                }),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: AppSizes.dropdownWidth,
                    child: DropdownButtonFormField<int?>(
                      initialValue: _selectedGen,
                      isDense: true,
                      alignment: Alignment.centerLeft,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.sm),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onChanged: (gen) => setState(() => _selectedGen = gen),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: SizedBox(
                            width: AppSizes.dropdownWidth - AppSpacing.lg,
                            child: Text(
                              context.l10n.filterAllGens,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        for (final gen in List.generate(9, (i) => i + 1))
                          DropdownMenuItem<int?>(
                            value: gen,
                            child: SizedBox(
                              width: AppSizes.dropdownWidth - AppSpacing.lg,
                              child: Text(
                                'Gen $gen',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
                                  icon: const Icon(Icons.edit),
                                  tooltip: context.l10n.manageEditTooltip,
                                  onPressed: () => Navigator.of(context).pop(
                                    ManageAction(pokemon: p, delete: false),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: context.l10n.manageDeleteTooltip,
                                  color: colors.error,
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
}
