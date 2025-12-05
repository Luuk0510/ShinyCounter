import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'package:shiny_counter/features/pokemon/presentation/bottom_sheets/edit_counters_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/bottom_sheets/edit_daily_counts_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/counter_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/widgets.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with WidgetsBindingObserver {
  late final CounterController _controller;
  late final PageController _spritePager;
  int _currentSpriteIndex = 0;
  bool _showNormal = false;
  bool _buttonPressed = false;
  List<String> _shinySprites = [];
  final Map<String, String?> _normalMap = {};

  @override
  void initState() {
    super.initState();
    _spritePager = PageController();
    _controller = CounterController(
      pokemon: widget.pokemon,
      sync: context.read<CounterSync>(),
      toggleCaughtUseCase: context.read<ToggleCaughtUseCase?>(),
    );
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onControllerChanged);
    _controller.init();
    _loadSprites();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _spritePager.dispose();
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
    if (parsed == null) return;
    final service = context.read<SpriteService>();
    final assets = await service.loadSprites();
    final shiny = assets.where((p) => p.dex == parsed.dex && p.shiny).toList()
      ..sort((a, b) => a.form.compareTo(b.form));
    final normal = assets.where((p) => p.dex == parsed.dex && !p.shiny).toList();
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
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.init();
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
    setState(() => _buttonPressed = true);
    await Future.delayed(AppAnim.fast);
    if (mounted) setState(() => _buttonPressed = false);
    await _toggleCaught();
  }

  Future<void> _showEditDialog() async {
    final result = await showModalBottomSheet<EditSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Builder(
          builder: (context) {
            final scopedCard = Theme.of(context).cardColor;
            return Container(color: scopedCard);
          },
        ),
        title: Text(
          widget.pokemon.name,
          style: Theme.of(context).textTheme.titleLarge?.merge(
            AppTypography.title.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: context.l10n.editCounterTooltip,
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: context.l10n.openOverlayTooltip,
            onPressed: _togglePill,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mediaQuery = MediaQuery.of(context);
          final bottomInset = mediaQuery.viewInsets.bottom;
          final isPortrait = mediaQuery.orientation == Orientation.portrait;
          final bottomPadding =
              mediaQuery.padding.bottom + bottomInset + (isPortrait ? 60 : 16);

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildImageSection(colors),
                    const SizedBox(height: AppSpacing.sm),
                    _buildCatchButton(colors),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CounterControls(
                            count: _controller.counter,
                            enabled: !_controller.isCaught,
                            onDecrement: _decrement,
                            onIncrement: _increment,
                            onEdit: _showEditDialog,
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
                                    onTap: _showEditDialog,
                                    child: HuntInfoCard(
                                      colors: colors,
                                      startedAt: _controller.startedAt,
                                      caughtAt: _controller.caughtAt,
                                      caughtGame: _controller.caughtGame,
                                      formatter: formatDate,
                                      onSelectGame: _showEditDialog,
                                      onGameChanged: (value) =>
                                          _controller.setCaughtGame(value),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _showDailyCountsEditor,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: DailyCountsList(
                                      colors: colors,
                                      dailyCounts: _controller.dailyCounts,
                                      dayFormatter: formatDayKey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
            child: PageView.builder(
              controller: _spritePager,
              itemCount: sprites.length,
              onPageChanged: (idx) => setState(() {
                _currentSpriteIndex = idx;
                _showNormal = false;
              }),
              itemBuilder: (context, index) {
                final shinyPath = sprites[index];
                final normalPath = _normalMap[shinyPath];
                final showNormal = _showNormal && normalPath != null;
                final path = showNormal ? normalPath! : shinyPath;
                final image = widget.pokemon.isLocalFile && !path.startsWith('assets/')
                    ? Image.file(
                        File(path),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.catching_pokemon,
                          size: AppSizes.detailImageFallback,
                        ),
                      )
                    : Image.asset(
                        path,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.catching_pokemon, 
                          size: AppSizes.detailImageFallback,
                        ),
                      );
                return Center(
                  child: AnimatedSwitcher(
                    duration: AppAnim.switcher,
                    transitionBuilder: (child, animation) => child,
                    child: SizedBox(
                      key: ValueKey(path),
                      width: AppSizes.detailImageSize,
                      height: AppSizes.detailImageSize,
                      child: image,
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
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _currentSpriteIndex
                      ? colors.primary
                      : colors.primary.withValues(alpha: 0.3),
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
    return AnimatedScale(
      scale: _buttonPressed ? AppAnim.buttonPressScale : 1,
      duration: AppAnim.fast,
      curve: AppAnim.easeOutCubic,
      child: AnimatedContainer(
        duration: AppAnim.normal,
        curve: AppAnim.easeOut,
        width: 150,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
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
                      fontSize: 18,
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
