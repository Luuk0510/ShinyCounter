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
import 'package:shiny_counter/features/pokemon/data/pokemon_names.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/widgets.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_ordering.dart';

// Toggle to include the full dex by default. Off preserves the original
// behavior (only custom/selected Pokémon).
const bool _includeBaseDex = false;

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage>
    with TickerProviderStateMixin {
  late final LoadCustomPokemonUseCase _loadCustomPokemon;
  late final SaveCustomPokemonUseCase _saveCustomPokemon;
  late final LoadCaughtUseCase _loadCaught;
  final List<Pokemon> _customPokemon = [];
  final List<Pokemon> _basePokemon = [];
  Set<String> _caught = {};
  bool _loading = true;
  final ScrollController _listController = ScrollController();
  bool _showUncaught = true;
  bool _showCaught = true;
  AnimationController? _sheetController;

  List<Pokemon> get _allPokemon {
    final combined = [..._basePokemon, ..._customPokemon];
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
    if (_includeBaseDex) {
      await _loadBasePokemon();
    }
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

  int? _genderPriority(String token) {
    switch (token) {
      case 'm':
      case 'md':
      case 'mo':
        return 0;
      case 'mf':
      case 'uk':
        return 1;
      case 'f':
      case 'fd':
      case 'fo':
        return 2;
      default:
        return null;
    }
  }

  Future<void> _loadBasePokemon() async {
    if (_basePokemon.isNotEmpty) return;
    try {
      final names = await PokemonNames.load();
      if (!mounted) return;
      final sprites = await context.read<SpriteService>().loadSprites();
      final chosen = <String, ParsedSprite>{};
      for (final sprite in sprites) {
        if (!sprite.shiny) continue;
        if (isMegaOrGmaxForm(sprite.form)) continue;
        final priority = _genderPriority(sprite.gender);
        if (priority == null) continue;
        final current = chosen[sprite.dex];
        if (current == null ||
            priority < _genderPriority(current.gender)! ||
            (priority == _genderPriority(current.gender)! &&
                sprite.form.compareTo(current.form) < 0)) {
          chosen[sprite.dex] = sprite;
        }
      }

      if (!mounted) return;
      setState(() {
        _basePokemon
          ..clear()
          ..addAll(
            chosen.values.map(
              (sprite) => Pokemon(
                id: sprite.dex,
                name: names.nameFor(sprite.dex),
                imagePath: sprite.path,
                isLocalFile: false,
              ),
            ),
          );
        _basePokemon.sort(pokemonDexComparator);
      });
    } catch (_) {
      // If assets fail to load we leave the base list empty; the UI still works
      // with custom Pokémon.
    }
  }

  Future<T?> _showScaledDialog<T>(Widget dialog) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: AppAnim.dialogDuration,
      pageBuilder: (context, animation, secondaryAnimation) => dialog,
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppAnim.dialogCurve,
        );
        final scale = Tween<double>(
          begin: AppAnim.dialogStartScale,
          end: 1,
        ).animate(curved);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
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
    final confirmed = await _showScaledDialog<bool>(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
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
                style: AppTypography.button.copyWith(color: colors.onSurface),
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
              style: AppTypography.button.copyWith(fontWeight: FontWeight.w700),
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
              style: AppTypography.button.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
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

    final action = await showModalBottomSheet<ManageAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      transitionAnimationController: _sheetController,
      backgroundColor: Theme.of(context).cardColor,
      barrierColor: Colors.black.withValues(alpha: AppOpacity.modalBarrier),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
      ),
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
    await _showScaledDialog(const SettingsDialog());
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedAppIcon(
                    assetPath: AppAssets.appIcon,
                    size: AppSizes.appBarTitleIcon,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(context.l10n.appTitle, style: AppTypography.title),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          iconSize: AppSizes.appBarActionIcon,
          icon: const Icon(Icons.add_circle),
          tooltip: context.l10n.tooltipAddPokemon,
          onPressed: _onAddPokemon,
        ),
        IconButton(
          iconSize: AppSizes.appBarActionIcon,
          icon: const Icon(Icons.edit_note),
          tooltip: context.l10n.tooltipManagePokemon,
          onPressed: _openManagePokemonList,
        ),
        IconButton(
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
        ),
      );
    }

    return Scrollbar(
      controller: _listController,
      thumbVisibility: false,
      interactive: true,
      radius: const Radius.circular(AppRadii.sm),
      thickness: AppSizes.listScrollbarThickness,
      child: ListView(
        controller: _listController,
        padding: EdgeInsets.fromLTRB(
          AppSizes.cardPaddingH - AppSpacing.xs,
          AppSpacing.xs,
          AppSizes.cardPaddingH - AppSpacing.xs,
          bottomPadding,
        ),
        children: sections,
      ),
    );
  }
}
