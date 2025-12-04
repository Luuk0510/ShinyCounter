import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';

import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/add_pokemon_dialog.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/edit_pokemon_dialog.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/pokemon_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/pokemon_empty_state.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/settings_sheet.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';

const _basePokemon = <Pokemon>[];

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  late final LoadCustomPokemonUseCase _loadCustomPokemon;
  late final SaveCustomPokemonUseCase _saveCustomPokemon;
  late final LoadCaughtUseCase _loadCaught;
  final List<Pokemon> _customPokemon = [];
  Set<String> _caught = {};
  bool _loading = true;

  List<Pokemon> get _allPokemon => [..._basePokemon, ..._customPokemon];

  @override
  void initState() {
    super.initState();
    _loadCustomPokemon = context.read<LoadCustomPokemonUseCase>();
    _saveCustomPokemon = context.read<SaveCustomPokemonUseCase>();
    _loadCaught = context.read<LoadCaughtUseCase>();
    _loadData();
  }

  Future<void> _loadData() async {
    final custom = await _loadCustomPokemon();
    setState(() {
      _customPokemon
        ..clear()
        ..addAll(custom);
    });
    await _reloadCaught();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _reloadCaught() async {
    final caught = await _loadCaught(_allPokemon);
    if (mounted) {
      setState(() => _caught = caught);
    }
  }

  bool _isCaught(Pokemon pokemon) => _caught.contains(pokemon.id);

  Future<void> _onAddPokemon() async {
    final newPokemon = await showAddPokemonDialog(context);
    if (newPokemon == null) return;

    setState(() {
      _customPokemon.add(newPokemon);
    });
    await _saveCustomPokemon(_customPokemon);
    await _reloadCaught();
  }

  Future<void> _applyPokemonEdit(Pokemon original, Pokemon updated) async {
    final index = _customPokemon.indexWhere((p) => p.id == original.id);
    if (index == -1) return;

    setState(() {
      _customPokemon[index] = updated;
    });

    await _saveCustomPokemon(_customPokemon);
    await _reloadCaught();
  }

  Future<void> _clearPokemonState(Pokemon pokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final counterKey = 'counter_${pokemon.id.toLowerCase()}';
    await prefs.remove(counterKey);
    await prefs.remove('caught_${pokemon.id.toLowerCase()}');
    await prefs.remove('${counterKey}_startedAt');
    await prefs.remove('${counterKey}_caughtAt');
    await prefs.remove('${counterKey}_dailyCounts');
  }

  Future<void> _confirmDelete(Pokemon pokemon) async {
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            context.l10n.confirmDeleteTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          content: Builder(
            builder: (context) {
              final message = context.l10n.confirmDeleteMessage(pokemon.name);
              final parts = message.split(pokemon.name);
              final after = parts.length > 1
                  ? parts.sublist(1).join(pokemon.name)
                  : '';
              return RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: colors.onSurface),
                  children: [
                    TextSpan(text: parts.first),
                    TextSpan(
                      text: pokemon.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(text: after),
                  ],
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(
                context.l10n.confirmDeleteCancel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(
                context.l10n.confirmDeleteDelete,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _customPokemon.removeWhere((p) => p.id == pokemon.id);
      });
      await _saveCustomPokemon(_customPokemon);
      await _clearPokemonState(pokemon);
      await _reloadCaught();
    }
  }

  Future<void> _openManagePokemonList() async {
    final pokemonSorted = [..._customPokemon]..sort(pokemonDexComparator);
    if (pokemonSorted.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.manageNoCustom)));
      }
      return;
    }

    final action = await showModalBottomSheet<_ManageAction>(
      context: context,
      showDragHandle: false,
      backgroundColor: Theme.of(context).cardColor,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.manageTitle,
                  style: AppTypography.sectionTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: pokemonSorted.length,
                    itemBuilder: (context, index) {
                      final p = pokemonSorted[index];
                      return ListTile(
                        title: Text(
                          p.name,
                          style: AppTypography.sectionTitle.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: context.l10n.manageEditTooltip,
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(_ManageAction(pokemon: p, delete: false)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: context.l10n.manageDeleteTooltip,
                              color: colors.error,
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(_ManageAction(pokemon: p, delete: true)),
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
        );
      },
    );

    if (action == null) return;
    if (!mounted) return;
    if (action.delete) {
      await _confirmDelete(action.pokemon);
    } else {
      final updated = await showEditPokemonDialog(context, action.pokemon);
      if (updated != null) {
        await _applyPokemonEdit(action.pokemon, updated);
      }
    }
  }

  Future<void> _openDetail(Pokemon pokemon) async {
    await context.goToPokemon(pokemon);
    await _reloadCaught();
  }

  Future<void> _openSettings() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final uncaught = _allPokemon.where((p) => !_isCaught(p)).toList()
      ..sort(pokemonDexComparator);
    final caught = _allPokemon.where((p) => _isCaught(p)).toList()
      ..sort(pokemonDexComparator);

    return Scaffold(
      appBar: _buildAppBar(colors),
      body: _buildBody(colors, bottomPadding, uncaught, caught),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colors) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 52,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Builder(
        builder: (context) {
          final scopedCard = Theme.of(context).cardColor;
          return Container(
            decoration: BoxDecoration(
              color: scopedCard,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          );
        },
      ),
      foregroundColor: colors.onSurface,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(context.l10n.appTitle, style: AppTypography.title),
      ),
      actions: [
        IconButton(
          iconSize: 26,
          icon: const Icon(Icons.add_circle),
          tooltip: context.l10n.tooltipAddPokemon,
          onPressed: _onAddPokemon,
        ),
        IconButton(
          iconSize: 26,
          icon: const Icon(Icons.edit_note),
          tooltip: context.l10n.tooltipManagePokemon,
          onPressed: _openManagePokemonList,
        ),
        IconButton(
          iconSize: 26,
          icon: const Icon(Icons.settings),
          tooltip: context.l10n.tooltipSettings,
          onPressed: _openSettings,
        ),
      ],
    );
  }

  Widget _buildBody(
    ColorScheme colors,
    double bottomPadding,
    List<Pokemon> uncaught,
    List<Pokemon> caught,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allPokemon.isEmpty) {
      return PokemonEmptyState(
        onAddPressed: _onAddPokemon,
        imageAsset: 'assets/icon/pokeball_icon.png',
        colors: colors,
        title: context.l10n.emptyTitle,
        actionLabel: context.l10n.emptyAction,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0, 4, 0, bottomPadding),
      itemCount: _sectionedCount(uncaught, caught),
      itemBuilder: (context, index) {
        final entry = _sectionedItem(context, uncaught, caught, index);
        if (entry is _SectionHeader) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(entry.title, style: AppTypography.sectionTitle),
          );
        } else if (entry is Pokemon) {
          return PokemonCard(
            pokemon: entry,
            isCaught: _isCaught(entry),
            onTap: () => _openDetail(entry),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

int _sectionedCount(List<Pokemon> uncaught, List<Pokemon> caught) {
  var count = 0;
  if (uncaught.isNotEmpty) {
    count += 1 + uncaught.length;
  }
  if (caught.isNotEmpty) {
    count += 1 + caught.length;
  }
  return count;
}

dynamic _sectionedItem(
  BuildContext context,
  List<Pokemon> uncaught,
  List<Pokemon> caught,
  int index,
) {
  var cursor = 0;

  if (uncaught.isNotEmpty) {
    if (index == cursor) return _SectionHeader(context.l10n.sectionUncaught);
    cursor += 1;
    if (index < cursor + uncaught.length) {
      return uncaught[index - cursor];
    }
    cursor += uncaught.length;
  }

  if (caught.isNotEmpty) {
    if (index == cursor) return _SectionHeader(context.l10n.sectionCaught);
    cursor += 1;
    if (index < cursor + caught.length) {
      return caught[index - cursor];
    }
  }

  return null;
}

class _SectionHeader {
  const _SectionHeader(this.title);
  final String title;
}

class _ManageAction {
  const _ManageAction({required this.pokemon, required this.delete});

  final Pokemon pokemon;
  final bool delete;
}
