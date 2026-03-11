import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/presentation/bottom_sheets/edit_counters_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/bottom_sheets/edit_daily_counts_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/counter_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/widgets.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/pokemon_sheets.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/formatters.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_ordering.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final CounterController _controller;
  late final PageController _spritePager;
  late final AnimationController _sparkleController;
  late final List<_SparkleBurstSpec> _sparkleBurst;
  int _currentSpriteIndex = 0;
  bool _showNormal = false;
  bool _buttonPressed = false;
  List<String> _shinySprites = [];
  final Map<String, String?> _normalMap = {};
  bool _spritesLoading = true;

  @override
  void initState() {
    super.initState();
    _spritePager = PageController();
    _sparkleController = AnimationController(
      vsync: this,
      duration: AppAnim.sparkleDuration,
    );
    _sparkleBurst = const [
      _SparkleBurstSpec(
        offset: Offset(-28, -18),
        delay: 0.0,
        scale: 1.0,
        turns: AppAnim.sparkleRotationTurns,
      ),
      _SparkleBurstSpec(
        offset: Offset(30, -10),
        delay: 0.08,
        scale: 0.85,
        turns: -AppAnim.sparkleRotationTurns * 0.9,
      ),
      _SparkleBurstSpec(
        offset: Offset(-22, 22),
        delay: 0.12,
        scale: 0.75,
        turns: AppAnim.sparkleRotationTurns * 0.7,
      ),
      _SparkleBurstSpec(
        offset: Offset(18, 28),
        delay: 0.16,
        scale: 0.7,
        turns: -AppAnim.sparkleRotationTurns * 0.6,
      ),
    ];
    _controller = CounterController(
      pokemon: widget.pokemon,
      sync: context.read<CounterSync>(),
    );
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onControllerChanged);
    _controller.initialize();
    _loadSprites();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _spritePager.dispose();
    _sparkleController.dispose();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadSprites() async {
    final parsed = SpriteParser.parse(widget.pokemon.imagePath.split('/').last);
    if (parsed == null) {
      if (mounted) {
        setState(() => _spritesLoading = false);
      }
      return;
    }
    setState(() => _spritesLoading = true);
    final service = context.read<SpriteService>();
    final assets = await service.spritesForDex(parsed.dex);
    if (!mounted) return;
    final shiny = assets.where((p) => p.shiny).toList()
      ..sort(compareSpritesForDetail);
    final normal = assets.where((p) => !p.shiny).toList()
      ..sort(compareSpritesForDetail);
    _normalMap.clear();
    for (final s in shiny) {
      final match = normal.firstWhere(
        (n) => n.form == s.form && n.gender == s.gender,
        orElse: () => s,
      );
      _normalMap[s.path] = match.shiny ? null : match.path;
    }
    setState(() {
      _shinySprites = shiny.map((e) => e.path).toList();
      _currentSpriteIndex = 0;
      _showNormal = false;
      _spritesLoading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.initialize();
    }
  }

  Future<void> _hapticTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> _increment() async {
    if (_controller.isCaught) return;
    await _hapticTap();
    await _controller.increment();
  }

  Future<void> _decrement() async {
    if (_controller.isCaught || _controller.counter == 0) return;
    await _hapticTap();
    await _controller.decrement();
  }

  Future<void> _toggleCaught() async {
    await _hapticTap();
    await _controller.toggleCaught();
  }

  Future<void> _handleCatchTap() async {
    final wasCaught = _controller.isCaught;
    setState(() => _buttonPressed = true);
    await Future.delayed(AppAnim.faster);
    if (mounted) setState(() => _buttonPressed = false);
    if (!wasCaught) {
      _sparkleController.forward(from: 0);
    }
    await _toggleCaught();
  }

  Future<void> _showEditDialog() async {
    final result = await showPokemonBottomSheet<EditSheetResult>(
      context,
      barrierOpacity: AppOpacity.detailSheetBarrier,
      builder: (context) {
        return EditCountersSheet(
          pokemonName: widget.pokemon.name,
          counter: _controller.counter,
          startedAt: _controller.startedAt,
          caughtAt: _controller.caughtAt,
          caughtGame: _controller.caughtGame,
        );
      },
    );

    if (result == null) return;
    if (result.counter != null && result.counter != _controller.counter) {
      await _controller.setCounterManual(result.counter!);
    }
    if (result.startedChanged) {
      await _controller.setStartedAtDate(result.startedAt);
    }
    if (result.caughtChanged) {
      await _controller.setCaughtAtDate(result.caughtAt);
    }
    if (result.gameChanged) {
      await _controller.setCaughtGame(result.caughtGame);
    }
  }

  Future<void> _togglePill() async {
    await _controller.toggleOverlay();
  }

  Future<void> _showDailyCountsEditor() async {
    final result = await showPokemonBottomSheet<Map<String, int>>(
      context,
      barrierOpacity: AppOpacity.detailSheetBarrier,
      builder: (context) {
        return EditDailyCountsSheet(
          dailyCounts: _controller.dailyCounts,
          dayFormatter: formatDayKey,
        );
      },
    );

    if (result == null) return;
    await _controller.setDailyCounts(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _DetailAppBar(
        pokemonName: widget.pokemon.name,
        onEdit: _showEditDialog,
        onTogglePill: _togglePill,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mediaQuery = MediaQuery.of(context);
          final bottomInset = mediaQuery.viewInsets.bottom;
          final isPortrait = mediaQuery.orientation == Orientation.portrait;
          final bottomPadding =
              mediaQuery.padding.bottom +
              bottomInset +
              (isPortrait ? AppSizes.cardPaddingH * 3 : AppSpacing.md);

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: AppInsets.page.copyWith(bottom: bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildImageSection(colors),
                    const SizedBox(height: AppSpacing.sm),
                    _buildCatchButton(colors),
                    _DetailInfoSection(
                      colors: colors,
                      controller: _controller,
                      onEdit: _showEditDialog,
                      onDailyCounts: _showDailyCountsEditor,
                      onGameChanged: (value) =>
                          _controller.setCaughtGame(value),
                      onIncrement: _increment,
                      onDecrement: _decrement,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(ColorScheme colors) {
    final sprites = <String>[widget.pokemon.imagePath];
    if (_shinySprites.isNotEmpty) {
      sprites
        ..clear()
        ..addAll(_shinySprites);
    } else {
      final normal = widget.pokemon.isLocalFile
          ? null
          : _deriveNormalPath(widget.pokemon.imagePath);
      if (normal != null && normal != widget.pokemon.imagePath) {
        sprites.add(normal);
      }
    }
    final canSwipe = sprites.length > 1;

    final assetPaths = <String>[];
    for (final path in sprites) {
      if (widget.pokemon.isLocalFile && !path.startsWith('assets/')) {
        precacheImage(pokemonImageProvider(path, isLocalFile: true), context);
      } else {
        assetPaths.add(path);
      }
      final normal = _normalMap[path];
      if (normal != null) {
        if (widget.pokemon.isLocalFile && !normal.startsWith('assets/')) {
          precacheImage(
            pokemonImageProvider(normal, isLocalFile: true),
            context,
          );
        } else {
          assetPaths.add(normal);
        }
      }
    }
    if (assetPaths.isNotEmpty) {
      final service = context.read<SpriteService>();
      unawaited(service.precacheSpritePaths(context, assetPaths));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final shiny = sprites[_currentSpriteIndex];
            final normal = _normalMap[shiny];
            if (normal != null) {
              setState(() => _showNormal = !_showNormal);
            }
          },
          child: SizedBox(
            height: AppSizes.detailImageSize,
            child: _spritesLoading
                ? const ShimmerBox(size: AppSizes.detailImageSize)
                : PageView.builder(
                    controller: _spritePager,
                    allowImplicitScrolling: true,
                    itemCount: sprites.length,
                    onPageChanged: (idx) => setState(() {
                      _currentSpriteIndex = idx;
                      _showNormal = false;
                    }),
                    itemBuilder: (context, index) {
                      final shinyPath = sprites[index];
                      final normalPath = _normalMap[shinyPath];
                      final showNormal = _showNormal && normalPath != null;
                      final path = showNormal ? normalPath : shinyPath;
                      return Center(
                        child: AnimatedSwitcher(
                          duration: AppAnim.switcher,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: SizedBox(
                            key: ValueKey(path),
                            width: AppSizes.detailImageSize,
                            height: AppSizes.detailImageSize,
                            child: PokemonImage(
                              path: path,
                              isLocalFile: widget.pokemon.isLocalFile,
                              borderRadius: 0,
                              fallbackIcon: Icons.catching_pokemon,
                              fallbackIconSize: AppSizes.detailImageFallback,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (canSwipe) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              sprites.length,
              (i) => AnimatedContainer(
                duration: AppAnim.switcher,
                curve: AppAnim.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                width: i == _currentSpriteIndex
                    ? AppSizes.pageIndicatorDotActive
                    : AppSizes.pageIndicatorDot,
                height: i == _currentSpriteIndex
                    ? AppSizes.pageIndicatorDotActive
                    : AppSizes.pageIndicatorDot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _currentSpriteIndex
                      ? AppButtonPalette.primaryFill(colors)
                      : AppButtonPalette.primaryFill(
                          colors,
                        ).withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCatchButton(ColorScheme colors) {
    final l10n = context.l10n;
    final caught = _controller.isCaught;
    final bg = caught ? Colors.green.shade600 : colors.secondary;
    final fg = caught ? Colors.black : colors.onSecondary;
    final button = AnimatedScale(
      scale: _buttonPressed ? AppAnim.buttonPressScale : 1,
      duration: AppAnim.fast,
      curve: AppAnim.easeOutCubic,
      child: AnimatedContainer(
        duration: AppAnim.fast,
        curve: AppAnim.easeOut,
        width: AppSizes.primaryButtonWidth,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('detail.catchButton'),
            borderRadius: BorderRadius.circular(AppRadii.md),
            onTap: _handleCatchTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: AnimatedSwitcher(
                duration: AppAnim.fast,
                child: Text(
                  caught ? l10n.buttonCaught : l10n.buttonCatch,
                  key: ValueKey(caught),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.buttonTextSize,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                transitionBuilder: (child, animation) => child,
              ),
            ),
          ),
        ),
      ),
    );
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                final t = _sparkleController.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final spec in _sparkleBurst)
                      _SparkleBurst(
                        spec: spec,
                        t: t,
                        baseSize: AppSizes.catchSparkleSize,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String? _deriveNormalPath(String shinyPath) {
    if (widget.pokemon.isLocalFile) return null;
    if (shinyPath.contains('_s.')) {
      return shinyPath.replaceFirst('_s.', '_n.');
    }
    if (shinyPath.contains('_r.')) {
      return shinyPath.replaceFirst('_r.', '_n.');
    }
    return null;
  }
}

class _SparkleBurstSpec {
  const _SparkleBurstSpec({
    required this.offset,
    required this.delay,
    required this.scale,
    required this.turns,
  });

  final Offset offset;
  final double delay;
  final double scale;
  final double turns;
}

class _SparkleBurst extends StatelessWidget {
  const _SparkleBurst({
    required this.spec,
    required this.t,
    required this.baseSize,
  });

  final _SparkleBurstSpec spec;
  final double t;
  final double baseSize;

  @override
  Widget build(BuildContext context) {
    final raw = (t - spec.delay) / (1 - spec.delay);
    final clamped = raw.clamp(0.0, 1.0);
    if (clamped == 0) {
      return const SizedBox.shrink();
    }
    final eased = AppAnim.easeOutCubic.transform(clamped);
    final fadeIn = AppAnim.sparkleFadeInFraction;
    final opacity = clamped <= fadeIn
        ? clamped / fadeIn
        : (1 - (clamped - fadeIn) / (1 - fadeIn));
    final scale =
        AppAnim.sparkleStartScale +
        (AppAnim.sparkleEndScale - AppAnim.sparkleStartScale) * eased;
    final turns = -spec.turns + (spec.turns * 2) * eased;
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: spec.offset * eased,
        child: Transform.rotate(
          angle: turns * 2 * math.pi,
          child: Transform.scale(
            scale: scale * spec.scale,
            child: Image.asset(
              AppAssets.sparkle,
              width: baseSize,
              height: baseSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar({
    required this.pokemonName,
    required this.onEdit,
    required this.onTogglePill,
  });

  final String pokemonName;
  final VoidCallback onEdit;
  final VoidCallback onTogglePill;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: AppSizes.toolbarHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(size: AppSizes.appBarActionIcon),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.lg),
        ),
      ),
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
      title: Text(
        pokemonName,
        style: Theme.of(context).textTheme.titleLarge?.merge(
          AppTypography.title.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      actions: [
        IconButton(
          iconSize: AppSizes.appBarActionIcon,
          icon: const Icon(Icons.edit),
          tooltip: context.l10n.editCounterTooltip,
          onPressed: onEdit,
        ),
        IconButton(
          iconSize: AppSizes.appBarActionIcon,
          icon: const Icon(Icons.open_in_new_rounded),
          tooltip: context.l10n.openOverlayTooltip,
          onPressed: onTogglePill,
        ),
      ],
    );
  }
}

class _DetailInfoSection extends StatelessWidget {
  const _DetailInfoSection({
    required this.colors,
    required this.controller,
    required this.onEdit,
    required this.onDailyCounts,
    required this.onGameChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ColorScheme colors;
  final CounterController controller;
  final VoidCallback onEdit;
  final VoidCallback onDailyCounts;
  final ValueChanged<String?> onGameChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CounterControls(
            count: controller.counter,
            enabled: !controller.isCaught,
            onDecrement: onDecrement,
            onIncrement: onIncrement,
            onEdit: onEdit,
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicWidth(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onEdit,
                    child: CountInfoCard(
                      colors: colors,
                      startedAt: controller.startedAt,
                      caughtAt: controller.caughtAt,
                      caughtGame: controller.caughtGame,
                      formatter: formatDate,
                      onSelectGame: onEdit,
                      onGameChanged: onGameChanged,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDailyCounts,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: DailyCountsList(
                      colors: colors,
                      dailyCounts: controller.dailyCounts,
                      dayFormatter: formatDayKey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
