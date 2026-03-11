import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_card_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/pokemon_stats_page_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/pokemon_sheets.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_action_builders.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/safe_area_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_app_bar.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_page_cards.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/formatters.dart';

class PokemonStatsPage extends StatefulWidget {
  const PokemonStatsPage({super.key});

  @override
  State<PokemonStatsPage> createState() => _PokemonStatsPageState();
}

class _PokemonStatsPageState extends State<PokemonStatsPage> {
  late final PokemonStatsPageController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = PokemonStatsPageController(
      repository: context.read<StatsRepository>(),
    );
    _controller.initialize();
  }

  Future<void> _pickChartRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: _controller.firstSelectableDate,
      lastDate: _controller.lastSelectableDate,
      initialDateRange: _controller.chartRange,
    );
    if (range == null || !mounted) return;
    _controller.applyChartRange(range);
  }

  void _resetChartRange() {
    _controller.resetChartRange();
  }

  void _openReorderSheet(
    Map<PokemonStatsCardId, PokemonStatsCardEntry> entries,
  ) {
    var workingOrder = _controller.orderFor(entries.keys);
    showPokemonBottomSheet<void>(
      context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        final maxHeight =
            MediaQuery.of(sheetContext).size.height *
            AppSizes.dialogHeightFactor;
        final colors = Theme.of(sheetContext).colorScheme;
        final resetOrder = _controller.resetOrderFor(entries.keys);
        return SafeAreaSheet(
          safeAreaTop: true,
          safeAreaBottom: true,
          padding: AppInsets.sheet,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.statsArrangeTitle,
                    style: AppTypography.title.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: ReorderableListView(
                      shrinkWrap: true,
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, _, _) {
                        return Material(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          elevation: 2,
                          child: child,
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        setSheetState(() {
                          final adjustedIndex = newIndex > oldIndex
                              ? newIndex - 1
                              : newIndex;
                          final moved = workingOrder.removeAt(oldIndex);
                          workingOrder.insert(adjustedIndex, moved);
                        });
                      },
                      children: [
                        for (
                          var index = 0;
                          index < workingOrder.length;
                          index++
                        )
                          Padding(
                            key: ValueKey(workingOrder[index]),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xxs,
                            ),
                            child: Material(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              child: ListTile(
                                title: Text(
                                  entries[workingOrder[index]]!.label,
                                  style: AppTypography.button.copyWith(
                                    fontSize: AppSizes.sheetFieldText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(
                                    Icons.drag_handle,
                                    size: AppSizes.statsReorderHandle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BottomSheetActionRow(
                    colors: colors,
                    leadingLabel: l10n.statsRangeReset,
                    trailingLabel: l10n.save,
                    spacing: AppSpacing.sm,
                    onLeadingPressed: () {
                      setSheetState(() => workingOrder = List.of(resetOrder));
                    },
                    onTrailingPressed: () {
                      _controller.setCardOrder(workingOrder);
                      Navigator.of(sheetContext).pop();
                    },
                    leadingTextStyle: AppTypography.button.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    trailingTextStyle: AppTypography.button.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildCardLayout(
    List<PokemonStatsCardEntry> entries,
    bool isWide,
  ) {
    if (!isWide) {
      return [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          entries[i].widget,
        ],
      ];
    }

    final rows = <Widget>[];
    var index = 0;
    while (index < entries.length) {
      final entry = entries[index];
      if (entry.span == 2 || index == entries.length - 1) {
        rows.add(entry.widget);
        index += 1;
      } else {
        final next = entries[index + 1];
        if (next.span == 2) {
          rows.add(entry.widget);
          index += 1;
        } else {
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: entry.widget),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: next.widget),
              ],
            ),
          );
          index += 2;
        }
      }
    }

    return [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpacing.lg),
        rows[i],
      ],
    ];
  }

  Map<PokemonStatsCardId, PokemonStatsCardEntry> _buildEntries(
    BuildContext context,
    ColorScheme colors,
  ) {
    final l10n = context.l10n;
    final summary = _controller.summary;
    final caught = StatsMetricCard(
      label: l10n.statsCaughtLabel,
      value: '${summary.caughtPokemon} / ${summary.totalPokemon}',
      colors: colors,
    );
    final total = StatsMetricCard(
      label: l10n.statsTotalCountsLabel,
      value: '${summary.totalCounts}',
      colors: colors,
    );
    final history = summary.dailyTotals.isEmpty
        ? null
        : StatsCountsChartCard(
            label: l10n.huntHistoryTitle,
            rangeLabel: _formatRangeLabel(_controller.chartRange),
            onPickRange: _pickChartRange,
            onResetRange: _resetChartRange,
            counts: summary.dailyTotals,
          );

    final gamesCard = summary.caughtGames.isEmpty
        ? null
        : StatsGamesCard(
            label: l10n.statsGamesLabel,
            games: summary.caughtGames,
            caughtByGame: summary.caughtByGame,
            parentController: _scrollController,
          );
    final recentCard = summary.recentCaught.isEmpty
        ? null
        : StatsRecentCard(
            label: l10n.statsRecentLabel,
            items: summary.recentCaught,
            parentController: _scrollController,
          );
    final resetsPokemonCard = summary.resetsByPokemon.isEmpty
        ? null
        : StatsPokemonResetsCard(
            label: l10n.statsResetsPokemonLabel,
            items: summary.resetsByPokemon,
            parentController: _scrollController,
          );
    final resetsCard = summary.resetsByGame.isEmpty
        ? null
        : StatsResetsCard(
            label: l10n.statsResetsByGameLabel,
            resets: summary.resetsByGame,
          );

    return <PokemonStatsCardId, PokemonStatsCardEntry>{
      PokemonStatsCardId.caught: PokemonStatsCardEntry(
        id: PokemonStatsCardId.caught,
        label: l10n.statsCaughtLabel,
        widget: caught,
        span: 1,
      ),
      PokemonStatsCardId.total: PokemonStatsCardEntry(
        id: PokemonStatsCardId.total,
        label: l10n.statsTotalCountsLabel,
        widget: total,
        span: 1,
      ),
      if (gamesCard != null)
        PokemonStatsCardId.games: PokemonStatsCardEntry(
          id: PokemonStatsCardId.games,
          label: l10n.statsGamesLabel,
          widget: gamesCard,
          span: 1,
        ),
      if (recentCard != null)
        PokemonStatsCardId.recent: PokemonStatsCardEntry(
          id: PokemonStatsCardId.recent,
          label: l10n.statsRecentLabel,
          widget: recentCard,
          span: 1,
        ),
      if (resetsPokemonCard != null)
        PokemonStatsCardId.resetsPokemon: PokemonStatsCardEntry(
          id: PokemonStatsCardId.resetsPokemon,
          label: l10n.statsResetsPokemonLabel,
          widget: resetsPokemonCard,
          span: 1,
        ),
      if (resetsCard != null)
        PokemonStatsCardId.resetsGame: PokemonStatsCardEntry(
          id: PokemonStatsCardId.resetsGame,
          label: l10n.statsResetsByGameLabel,
          widget: resetsCard,
          span: 1,
        ),
      if (history != null)
        PokemonStatsCardId.history: PokemonStatsCardEntry(
          id: PokemonStatsCardId.history,
          label: l10n.huntHistoryTitle,
          widget: history,
          span: 2,
        ),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: StatsAppBar(
            title: Text(
              l10n.statsTitle,
              style: Theme.of(context).textTheme.titleLarge?.merge(
                AppTypography.title.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            actions: [
              IconButton(
                tooltip: l10n.statsEditLayout,
                onPressed: _controller.loading
                    ? null
                    : () => _openReorderSheet(_buildEntries(context, colors)),
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          body: _controller.loading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    final entries = _buildEntries(context, colors);
                    final ordered = _controller.orderedValues(entries);
                    final viewInset = MediaQuery.of(context).viewPadding.bottom;
                    return ListView(
                      controller: _scrollController,
                      padding: AppInsets.pageWithBottomInset(viewInset),
                      children: _buildCardLayout(ordered, isWide),
                    );
                  },
                ),
        );
      },
    );
  }
}

String _formatRangeLabel(DateTimeRange range) {
  return '${formatDate(range.start)} – ${formatDate(range.end)}';
}
