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
import 'package:shiny_counter/features/pokemon/shared/state/counter_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/widgets.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/pokemon_sheets.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

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
      sync: context.read<CounterSync>(),
      toggleCaughtUseCase: context.read<ToggleCaughtUseCase?>(),
    );
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onControllerChanged);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
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
                    DetailSpriteViewer(pokemon: widget.pokemon),
                    const SizedBox(height: AppSpacing.sm),
                    CatchButton(
                      caught: _controller.isCaught,
                      onTap: _toggleCaught,
                    ),
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
    return RoundedAppBar(
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
