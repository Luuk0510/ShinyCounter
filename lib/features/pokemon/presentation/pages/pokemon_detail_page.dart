import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/bottom_sheets/edit_counters_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/counter_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/hunt_info_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/daily_counts_list.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail_header.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/counter_controls.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with WidgetsBindingObserver {
  late final CounterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CounterController(
      pokemon: widget.pokemon,
      sync: context.read(),
      toggleCaughtUseCase: context.read(),
    );
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(() => mounted ? setState(() {}) : null);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
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
              mediaQuery.padding.bottom + bottomInset + (isPortrait ? 110 : 24);

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    DetailHeader(
                      pokemon: widget.pokemon,
                      colors: colors,
                      isCaught: _controller.isCaught,
                      onToggleCaught: _toggleCaught,
                    ),
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
                          const SizedBox(height: AppSpacing.xxl),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IntrinsicWidth(
                                  child: HuntInfoCard(
                                    colors: colors,
                                    startedAt: _controller.startedAt,
                                    caughtAt: _controller.caughtAt,
                                    caughtGame: _controller.caughtGame,
                                    formatter: _formatDate,
                                    onSelectGame: _showEditDialog,
                                    onGameChanged: (value) =>
                                        _controller.setCaughtGame(value),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                  ),
                                  child: DailyCountsList(
                                    colors: colors,
                                    dailyCounts: _controller.dailyCounts,
                                    dayFormatter: _formatDayKey,
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

  String _formatDate(DateTime? value) {
    if (value == null) return '--';
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.day)}-${two(local.month)}-${local.year}';
  }

  String _formatDayKey(String key) {
    final parsed = DateTime.tryParse(key);
    if (parsed == null) return key;
    String two(int v) => v.toString().padLeft(2, '0');
    final local = parsed.toLocal();
    return '${two(local.day)}-${two(local.month)}-${local.year}';
  }
}
