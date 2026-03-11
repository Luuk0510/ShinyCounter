import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
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
      appBar: DetailAppBar(
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
                    DetailSpriteGallery(
                      colors: colors,
                      pokemon: widget.pokemon,
                      spritePager: _spritePager,
                      currentSpriteIndex: _currentSpriteIndex,
                      showNormal: _showNormal,
                      spritesLoading: _spritesLoading,
                      shinySprites: _shinySprites,
                      normalMap: _normalMap,
                      spriteService: context.read<SpriteService>(),
                      onToggleVariant: () =>
                          setState(() => _showNormal = !_showNormal),
                      onPageChanged: (idx) => setState(() {
                        _currentSpriteIndex = idx;
                        _showNormal = false;
                      }),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CatchStatusButton(
                      colors: colors,
                      caught: _controller.isCaught,
                      buttonPressed: _buttonPressed,
                      sparkleAnimation: _sparkleController,
                      onTap: _handleCatchTap,
                    ),
                    DetailInfoSection(
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
}
