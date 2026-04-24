import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';

import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/widgets.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/dialogs.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/pokemon_sheets.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';

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
  late final LoadCustomPokemonUseCase _loadCustomPokemon;
  late final SaveCustomPokemonUseCase _saveCustomPokemon;
  late final LoadCaughtUseCase _loadCaught;
  final List<Pokemon> _customPokemon = [];
  Set<String> _caught = {};
  bool _loading = true;
  final ScrollController _listController = ScrollController();
  bool _showUncaught = true;
  bool _showCaught = true;
  AnimationController? _sheetController;

  bool _isCustomPokemon(Pokemon pokemon) {
    return _customPokemon.any((p) => p.id == pokemon.id);
  }

  List<Pokemon> get _allPokemon {
    final combined = [..._customPokemon];
    combined.sort(pokemonDexComparator);
    return combined;
  }

  @override
  void initState() {
    super.initState();
    _loadCustomPokemon = context.read<LoadCustomPokemonUseCase>();
    _saveCustomPokemon = context.read<SaveCustomPokemonUseCase>();
    _loadCaught = context.read<LoadCaughtUseCase>();
    _sheetController = AnimationController(
      vsync: this,
      duration: AppAnim.sheetDuration,
      reverseDuration: AppAnim.sheetDuration,
    );
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
      _precacheListSprites();
    }
  }

  Future<void> _reloadCaught() async {
    final caught = await _loadCaught(_allPokemon);
    if (mounted) {
      setState(() => _caught = caught);
    }
  }

  bool _isCaught(Pokemon pokemon) => _caught.contains(pokemon.id);

  Future<void> _precacheListSprites() async {
    final toPrecache = _allPokemon
        .where((p) => !p.isLocalFile)
        .take(AppLimits.listSpritePrecacheCount)
        .toList();
    if (toPrecache.isEmpty) return;
    final service = context.read<SpriteService>();
    await service.precacheSpritePaths(
      context,
      toPrecache.map((p) => p.imagePath),
    );
    final dexes = <String>[];
    for (final p in toPrecache) {
      final parsed = SpriteParser.parse(p.imagePath.split('/').last);
      if (parsed != null) dexes.add(parsed.dex);
    }
    if (dexes.isNotEmpty) {
      await service.warmupForDexes(dexes);
    }
  }

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
    await context.read<CounterSync>().clearPokemonState(pokemon.id);
  }

  Future<void> _confirmDelete(Pokemon pokemon) async {
    final colors = Theme.of(context).colorScheme;
    final message = context.l10n.confirmDeleteMessage(pokemon.name);
    final parts = message.split(pokemon.name);
    final after = parts.length > 1 ? parts.sublist(1).join(pokemon.name) : '';
    final confirmed = await showConfirmDialog(
      context: context,
      title: Text(
        '${context.l10n.confirmDeleteTitle} ${pokemon.name}',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      content: RichText(
        text: TextSpan(
          style: AppTypography.button.copyWith(color: colors.onSurface),
          children: [
            TextSpan(text: parts.first),
            TextSpan(
              text: pokemon.name,
              style: AppTypography.button.copyWith(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: after),
          ],
        ),
      ),
      cancelLabel: context.l10n.confirmDeleteCancel,
      confirmLabel: context.l10n.confirmDeleteDelete,
      destructive: true,
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

  @override
  void dispose() {
    _sheetController?.dispose();
    _listController.dispose();
    super.dispose();
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

    final action = await showPokemonBottomSheet<ManageAction>(
      context,
      showDragHandle: false,
      transitionController: _sheetController,
      builder: (context) => ManageListView(pokemonSorted: pokemonSorted),
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
    await showScaledDialog(
      context: context,
      builder: (_) => const SettingsDialog(),
    );
    if (!mounted) return;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final uncaught = _allPokemon.where((p) => !_isCaught(p)).toList()
      ..sort(pokemonDexComparator);
    final caught = _allPokemon.where((p) => _isCaught(p)).toList()
      ..sort(pokemonDexComparator);

    return Scaffold(
      appBar: _buildAppBar(colors),
      body: _buildBody(colors, uncaught, caught),
      bottomNavigationBar: _ListBottomBar(
        onStats: () => context.goToStats(),
        onAdd: _onAddPokemon,
        onManage: _openManagePokemonList,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colors) {
    return RoundedAppBar(
      foregroundColor: colors.onSurface,
      title: _ListAppBarTitle(title: context.l10n.appTitle),
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

  Widget _buildBody(
    ColorScheme colors,
    List<Pokemon> uncaught,
    List<Pokemon> caught,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allPokemon.isEmpty) {
      return PokemonEmptyState(
        onAddPressed: _onAddPokemon,
        imageAsset: AppAssets.pokeballIcon,
        colors: colors,
        title: context.l10n.emptyTitle,
        actionLabel: context.l10n.emptyAction,
      );
    }

    final sections = <Widget>[];
    if (uncaught.isNotEmpty) {
      sections.add(
        PokemonSection(
          title: context.l10n.sectionUncaught,
          expanded: _showUncaught,
          onToggle: () => setState(() => _showUncaught = !_showUncaught),
          pokemons: uncaught,
          isCaught: _isCaught,
          onTap: _openDetail,
          canManage: _isCustomPokemon,
          onEdit: (pokemon) async {
            if (!_isCustomPokemon(pokemon)) return;
            final updated = await showEditPokemonDialog(context, pokemon);
            if (updated != null) {
              await _applyPokemonEdit(pokemon, updated);
            }
          },
          onDelete: (pokemon) async {
            if (!_isCustomPokemon(pokemon)) return;
            await _confirmDelete(pokemon);
          },
        ),
      );
    }
    if (caught.isNotEmpty) {
      sections.add(
        PokemonSection(
          title: context.l10n.sectionCaught,
          expanded: _showCaught,
          onToggle: () => setState(() => _showCaught = !_showCaught),
          pokemons: caught,
          isCaught: _isCaught,
          onTap: _openDetail,
          canManage: _isCustomPokemon,
          onEdit: (pokemon) async {
            if (!_isCustomPokemon(pokemon)) return;
            final updated = await showEditPokemonDialog(context, pokemon);
            if (updated != null) {
              await _applyPokemonEdit(pokemon, updated);
            }
          },
          onDelete: (pokemon) async {
            if (!_isCustomPokemon(pokemon)) return;
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
