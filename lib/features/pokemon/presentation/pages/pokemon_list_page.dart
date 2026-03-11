import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';

import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/pokemon_list_page_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/widgets.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/dialogs.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/pokemon_sheets.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_action_builders.dart';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  static const Key addPokemonKey = Key('list.addPokemon');
  static const Key managePokemonKey = Key('list.managePokemon');
  static const Key settingsKey = Key('list.settings');
  static const Key statsKey = Key('list.stats');

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage>
    with TickerProviderStateMixin {
  late final PokemonListPageController _controller;
  final ScrollController _listController = ScrollController();
  AnimationController? _sheetController;

  @override
  void initState() {
    super.initState();
    _controller = PokemonListPageController(
      pokemonRepository: context.read(),
      counterSync: context.read(),
      spriteService: context.read(),
    );
    _sheetController = AnimationController(
      vsync: this,
      duration: AppAnim.sheetDuration,
      reverseDuration: AppAnim.sheetDuration,
    );
    _controller.initialize(context);
  }

  Future<void> _onAddPokemon() async {
    final newPokemon = await showAddPokemonDialog(context);
    if (newPokemon == null) return;
    await _controller.addPokemon(newPokemon);
  }

  Future<void> _applyPokemonEdit(Pokemon original, Pokemon updated) async {
    await _controller.applyPokemonEdit(original, updated);
  }

  Future<void> _confirmDelete(Pokemon pokemon) async {
    final confirmed = await showScaledDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: Text(
          '${context.l10n.confirmDeleteTitle} ${pokemon.name}',
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
                style: AppTypography.button.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(text: parts.first),
                  TextSpan(
                    text: pokemon.name,
                    style: AppTypography.button.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: after),
                ],
              ),
            );
          },
        ),
        cancelLabel: context.l10n.confirmDeleteCancel,
        confirmLabel: context.l10n.confirmDeleteDelete,
        destructiveConfirm: true,
      ),
    );

    if (confirmed == true) {
      await _controller.deletePokemonAndState(pokemon);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _sheetController?.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _openManagePokemonList() async {
    final pokemonSorted = _controller.customPokemonSorted;
    if (pokemonSorted.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.manageNoCustom)));
      }
      return;
    }

    final action = await showPokemonBottomSheet<ManageAction>(
      context,
      showDragHandle: false,
      transitionController: _sheetController,
      builder: (context) => ManageListView(pokemonSorted: pokemonSorted),
    );

    if (action == null || !mounted) return;
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
    await _controller.reloadCaught();
  }

  Future<void> _openSettings() async {
    if (!mounted) return;
    await showScaledDialog(
      context: context,
      builder: (_) => const SettingsDialog(),
    );
    if (!mounted) return;
    await _controller.refresh(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(colors),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _buildBody(colors),
      ),
      bottomNavigationBar: _ListBottomBar(
        onStats: () => context.goToStats(),
        onAdd: _onAddPokemon,
        onManage: _openManagePokemonList,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colors) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: AppSizes.toolbarHeight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.lg),
        ),
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
                bottom: Radius.circular(AppRadii.lg),
              ),
            ),
          );
        },
      ),
      foregroundColor: colors.onSurface,
      title: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: _ListAppBarTitle(title: context.l10n.appTitle),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          key: PokemonListPage.settingsKey,
          iconSize: AppSizes.appBarActionIcon,
          icon: const Icon(Icons.settings),
          tooltip: context.l10n.tooltipSettings,
          onPressed: _openSettings,
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.allPokemon.isEmpty) {
      return PokemonEmptyState(
        onAddPressed: _onAddPokemon,
        imageAsset: AppAssets.pokeballIcon,
        colors: colors,
        title: context.l10n.emptyTitle,
        actionLabel: context.l10n.emptyAction,
      );
    }

    final uncaught = _controller.uncaughtPokemonSorted;
    final caught = _controller.caughtPokemonSorted;
    final sections = <Widget>[];
    if (uncaught.isNotEmpty) {
      sections.add(
        PokemonSection(
          title: context.l10n.sectionUncaught,
          expanded: _controller.showUncaught,
          onToggle: _controller.toggleUncaughtSection,
          pokemons: uncaught,
          isCaught: _controller.isCaught,
          onTap: _openDetail,
          canManage: _controller.isCustomPokemon,
          onEdit: (pokemon) async {
            if (!_controller.isCustomPokemon(pokemon)) return;
            final updated = await showEditPokemonDialog(context, pokemon);
            if (updated != null) {
              await _applyPokemonEdit(pokemon, updated);
            }
          },
          onDelete: (pokemon) async {
            if (!_controller.isCustomPokemon(pokemon)) return;
            await _confirmDelete(pokemon);
          },
        ),
      );
    }
    if (caught.isNotEmpty) {
      sections.add(
        PokemonSection(
          title: context.l10n.sectionCaught,
          expanded: _controller.showCaught,
          onToggle: _controller.toggleCaughtSection,
          pokemons: caught,
          isCaught: _controller.isCaught,
          onTap: _openDetail,
          canManage: _controller.isCustomPokemon,
          onEdit: (pokemon) async {
            if (!_controller.isCustomPokemon(pokemon)) return;
            final updated = await showEditPokemonDialog(context, pokemon);
            if (updated != null) {
              await _applyPokemonEdit(pokemon, updated);
            }
          },
          onDelete: (pokemon) async {
            if (!_controller.isCustomPokemon(pokemon)) return;
            await _confirmDelete(pokemon);
          },
        ),
      );
    }

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Scrollbar(
        controller: _listController,
        thumbVisibility: false,
        interactive: true,
        radius: const Radius.circular(AppRadii.sm),
        thickness: AppSizes.listScrollbarThickness,
        child: ListView(
          controller: _listController,
          padding: AppInsets.page.copyWith(bottom: AppSpacing.xs),
          children: sections,
        ),
      ),
    );
  }
}

class _ListAppBarTitle extends StatelessWidget {
  const _ListAppBarTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedAppIcon(
          assetPath: AppAssets.appIcon,
          size: AppSizes.appBarTitleIcon,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(title, style: AppTypography.title),
      ],
    );
  }
}

class _ListBottomBar extends StatelessWidget {
  const _ListBottomBar({
    required this.onStats,
    required this.onAdd,
    required this.onManage,
  });

  final VoidCallback onStats;
  final VoidCallback onAdd;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Material(
        color: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            children: [
              _BottomAction(
                key: PokemonListPage.statsKey,
                icon: Icons.bar_chart_rounded,
                label: l10n.statsTitle,
                onTap: onStats,
                colors: colors,
              ),
              _BottomAction(
                key: PokemonListPage.addPokemonKey,
                icon: Icons.add_circle,
                label: l10n.tooltipAddPokemon,
                onTap: onAdd,
                colors: colors,
              ),
              _BottomAction(
                key: PokemonListPage.managePokemonKey,
                icon: Icons.edit_note,
                label: l10n.tooltipManagePokemon,
                onTap: onManage,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: colors.onSurface,
    );
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: kBottomNavigationBarHeight,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.appBarActionIcon,
              color: colors.onSurface,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: labelStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
