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
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_action_builders.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/safe_area_sheet.dart';
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

    return <_StatsCardId, _StatsCardEntry>{
      _StatsCardId.caught: _entry(
        _StatsCardId.caught,
        label: l10n.statsCaughtLabel,
        widget: caught,
      ),
      _StatsCardId.total: _entry(
        _StatsCardId.total,
        label: l10n.statsTotalCountsLabel,
        widget: total,
      ),
      if (gamesCard != null)
        _StatsCardId.games: _entry(
          _StatsCardId.games,
          label: l10n.statsGamesLabel,
          widget: gamesCard,
        ),
      if (recentCard != null)
        _StatsCardId.recent: _entry(
          _StatsCardId.recent,
          label: l10n.statsRecentLabel,
          widget: recentCard,
        ),
      if (resetsPokemonCard != null)
        _StatsCardId.resetsPokemon: _entry(
          _StatsCardId.resetsPokemon,
          label: l10n.statsResetsPokemonLabel,
          widget: resetsPokemonCard,
        ),
      if (resetsCard != null)
        _StatsCardId.resetsGame: _entry(
          _StatsCardId.resetsGame,
          label: l10n.statsResetsByGameLabel,
          widget: resetsCard,
        ),
      if (history != null)
        _StatsCardId.history: _entry(
          _StatsCardId.history,
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
    );
  }
}

_StatsCardEntry _entry(
  _StatsCardId id, {
  required String label,
  required Widget widget,
  int span = 1,
}) {
  return _StatsCardEntry(id: id, label: label, widget: widget, span: span);
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
