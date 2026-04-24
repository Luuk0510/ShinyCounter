import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/counter_state.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/date_range.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/stats_models.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/safe_area_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/pokemon_sheets.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_app_bar.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_games_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_metric_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_recent_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_resets_card.dart';
import 'package:shiny_counter/features/pokemon/domain/services/stats_aggregation_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

class PokemonStatsPage extends StatefulWidget {
  const PokemonStatsPage({super.key});

  @override
  State<PokemonStatsPage> createState() => _PokemonStatsPageState();
}

class _PokemonStatsPageState extends State<PokemonStatsPage> {
  static const int _defaultChartDays = 30;
  static const List<_StatsCardId> _defaultCardOrder = [
    _StatsCardId.caught,
    _StatsCardId.total,
    _StatsCardId.games,
    _StatsCardId.recent,
    _StatsCardId.resetsPokemon,
    _StatsCardId.resetsGame,
    _StatsCardId.history,
  ];

  late final StatsAggregationService _statsService;
  late DateTimeRange _chartRange;
  List<CounterState> _states = const [];
  bool _loading = true;
  StatsSummary _summary = const StatsSummary.empty();
  final ScrollController _scrollController = ScrollController();
  late List<_StatsCardId> _cardOrder;

  @override
  void initState() {
    super.initState();
    _statsService = StatsAggregationService(
      repository: context.read<StatsRepository>(),
    );
    _chartRange = _defaultChartRange();
    _cardOrder = List.of(_defaultCardOrder);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final snapshot = await _statsService.loadStats(
      _domainRangeFromUiRange(_chartRange),
    );
    if (!mounted) return;
    setState(() {
      _states = snapshot.states;
      _summary = snapshot.summary;
      _loading = false;
    });
  }

  DateTimeRange _defaultChartRange() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(const Duration(days: _defaultChartDays - 1));
    return DateTimeRange(start: start, end: end);
  }

  Future<void> _pickChartRange() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year, now.month, now.day);
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final range = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _chartRange,
    );
    if (range == null) return;
    if (!mounted) return;
    setState(() {
      _chartRange = range;
      _summary = _statsService.updateSummaryForRange(
        _summary,
        _states,
        _domainRangeFromUiRange(range),
      );
    });
  }

  void _resetChartRange() {
    final range = _defaultChartRange();
    setState(() {
      _chartRange = range;
      _summary = _statsService.updateSummaryForRange(
        _summary,
        _states,
        _domainRangeFromUiRange(range),
      );
    });
  }

  DateRange _domainRangeFromUiRange(DateTimeRange range) {
    return DateRange(start: range.start, end: range.end);
  }

  void _openReorderSheet(Map<_StatsCardId, _StatsCardEntry> entries) {
    final order = _cardOrder.where(entries.containsKey).toList(growable: true);
    for (final id in entries.keys) {
      if (!order.contains(id)) {
        order.add(id);
      }
    }
    var workingOrder = List<_StatsCardId>.of(order);
    showPokemonBottomSheet<void>(
      context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        final maxHeight =
            MediaQuery.of(sheetContext).size.height *
            AppSizes.dialogHeightFactor;
        final colors = Theme.of(sheetContext).colorScheme;
        final resetOrder = [
          for (final id in _defaultCardOrder)
            if (entries.containsKey(id)) id,
          for (final id in entries.keys)
            if (!_defaultCardOrder.contains(id)) id,
        ];
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(
                              () => workingOrder = List.of(resetOrder),
                            );
                          },
                          style: AppButtonStyles.primaryOutline(
                            colors,
                            useLighter: true,
                          ),
                          child: Text(
                            l10n.statsRangeReset,
                            style: AppTypography.button.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _cardOrder = List.of(workingOrder));
                            Navigator.of(sheetContext).pop();
                          },
                          style: AppButtonStyles.primaryFilled(colors),
                          child: Text(
                            l10n.save,
                            style: AppTypography.button.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildCardLayout(List<_StatsCardEntry> entries, bool isWide) {
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

  Map<_StatsCardId, _StatsCardEntry> _buildEntries(
    BuildContext context,
    ColorScheme colors,
  ) {
    final l10n = context.l10n;
    final caught = StatsMetricCard(
      label: l10n.statsCaughtLabel,
      value: '${_summary.caughtPokemon} / ${_summary.totalPokemon}',
      colors: colors,
    );
    final total = StatsMetricCard(
      label: l10n.statsTotalCountsLabel,
      value: '${_summary.totalCounts}',
      colors: colors,
    );
    final history = _summary.dailyTotals.isEmpty
        ? null
        : StatsCountsChartCard(
            label: l10n.huntHistoryTitle,
            rangeLabel: _formatRangeLabel(_chartRange),
            onPickRange: _pickChartRange,
            onResetRange: _resetChartRange,
            counts: _summary.dailyTotals,
          );

    final gamesCard = _summary.caughtGames.isEmpty
        ? null
        : StatsGamesCard(
            label: l10n.statsGamesLabel,
            games: _summary.caughtGames,
            caughtByGame: _summary.caughtByGame,
            parentController: _scrollController,
          );
    final recentCard = _summary.recentCaught.isEmpty
        ? null
        : StatsRecentCard(
            label: l10n.statsRecentLabel,
            items: _summary.recentCaught,
            parentController: _scrollController,
          );
    final resetsPokemonCard = _summary.resetsByPokemon.isEmpty
        ? null
        : StatsPokemonResetsCard(
            label: l10n.statsResetsPokemonLabel,
            items: _summary.resetsByPokemon,
            parentController: _scrollController,
          );
    final resetsCard = _summary.resetsByGame.isEmpty
        ? null
        : StatsResetsCard(
            label: l10n.statsResetsByGameLabel,
            resets: _summary.resetsByGame,
          );

    return <_StatsCardId, _StatsCardEntry>{
      _StatsCardId.caught: _StatsCardEntry(
        id: _StatsCardId.caught,
        label: l10n.statsCaughtLabel,
        widget: caught,
        span: 1,
      ),
      _StatsCardId.total: _StatsCardEntry(
        id: _StatsCardId.total,
        label: l10n.statsTotalCountsLabel,
        widget: total,
        span: 1,
      ),
      if (gamesCard != null)
        _StatsCardId.games: _StatsCardEntry(
          id: _StatsCardId.games,
          label: l10n.statsGamesLabel,
          widget: gamesCard,
          span: 1,
        ),
      if (recentCard != null)
        _StatsCardId.recent: _StatsCardEntry(
          id: _StatsCardId.recent,
          label: l10n.statsRecentLabel,
          widget: recentCard,
          span: 1,
        ),
      if (resetsPokemonCard != null)
        _StatsCardId.resetsPokemon: _StatsCardEntry(
          id: _StatsCardId.resetsPokemon,
          label: l10n.statsResetsPokemonLabel,
          widget: resetsPokemonCard,
          span: 1,
        ),
      if (resetsCard != null)
        _StatsCardId.resetsGame: _StatsCardEntry(
          id: _StatsCardId.resetsGame,
          label: l10n.statsResetsByGameLabel,
          widget: resetsCard,
          span: 1,
        ),
      if (history != null)
        _StatsCardId.history: _StatsCardEntry(
          id: _StatsCardId.history,
          label: l10n.huntHistoryTitle,
          widget: history,
          span: 2,
        ),
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

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
            onPressed: _loading
                ? null
                : () => _openReorderSheet(_buildEntries(context, colors)),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                final entries = _buildEntries(context, colors);
                final ordered = <_StatsCardEntry>[];
                final order = _cardOrder
                    .where(entries.containsKey)
                    .toList(growable: true);
                for (final id in entries.keys) {
                  if (!order.contains(id)) {
                    order.add(id);
                  }
                }
                for (final id in order) {
                  ordered.add(entries[id]!);
                }
                final viewInset = MediaQuery.of(context).viewPadding.bottom;
                return ListView(
                  controller: _scrollController,
                  padding: AppInsets.pageWithBottomInset(viewInset),
                  children: _buildCardLayout(ordered, isWide),
                );
              },
            ),
    );
  }
}

String _formatRangeLabel(DateTimeRange range) {
  return '${formatDate(range.start)} – ${formatDate(range.end)}';
}

enum _StatsCardId {
  caught,
  total,
  games,
  recent,
  resetsPokemon,
  resetsGame,
  history,
}

class _StatsCardEntry {
  const _StatsCardEntry({
    required this.id,
    required this.label,
    required this.widget,
    required this.span,
  });

  final _StatsCardId id;
  final String label;
  final Widget widget;
  final int span;
}
