import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/pokemon_stats_page_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/pokemon_sheets.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/safe_area_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_app_bar.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_counts_chart.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_resets_pie_chart.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';
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
    _controller.loadStats();
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

  void _openReorderSheet(Map<StatsCardId, _StatsCardEntry> entries) {
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
                            _controller.setCardOrder(workingOrder);
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

  Map<StatsCardId, _StatsCardEntry> _buildEntries(
    BuildContext context,
    ColorScheme colors,
  ) {
    final l10n = context.l10n;
    final summary = _controller.summary;
    final caught = _StatsMetricCard(
      label: l10n.statsCaughtLabel,
      value: '${summary.caughtPokemon} / ${summary.totalPokemon}',
      colors: colors,
    );
    final total = _StatsMetricCard(
      label: l10n.statsTotalCountsLabel,
      value: '${summary.totalCounts}',
      colors: colors,
    );
    final history = summary.dailyTotals.isEmpty
        ? null
        : _StatsCountsChartCard(
            label: l10n.huntHistoryTitle,
            rangeLabel: _formatRangeLabel(_controller.chartRange),
            onPickRange: _pickChartRange,
            onResetRange: _resetChartRange,
            counts: summary.dailyTotals,
          );

    final gamesCard = summary.caughtGames.isEmpty
        ? null
        : _StatsGamesCard(
            label: l10n.statsGamesLabel,
            games: summary.caughtGames,
            caughtByGame: summary.caughtByGame,
            parentController: _scrollController,
          );
    final recentCard = summary.recentCaught.isEmpty
        ? null
        : _StatsRecentCard(
            label: l10n.statsRecentLabel,
            items: summary.recentCaught,
            parentController: _scrollController,
          );
    final resetsPokemonCard = summary.resetsByPokemon.isEmpty
        ? null
        : _StatsPokemonResetsCard(
            label: l10n.statsResetsPokemonLabel,
            items: summary.resetsByPokemon,
            parentController: _scrollController,
          );
    final resetsCard = summary.resetsByGame.isEmpty
        ? null
        : _StatsResetsCard(
            label: l10n.statsResetsByGameLabel,
            resets: summary.resetsByGame,
          );

    return <StatsCardId, _StatsCardEntry>{
      StatsCardId.caught: _StatsCardEntry(
        id: StatsCardId.caught,
        label: l10n.statsCaughtLabel,
        widget: caught,
        span: 1,
      ),
      StatsCardId.total: _StatsCardEntry(
        id: StatsCardId.total,
        label: l10n.statsTotalCountsLabel,
        widget: total,
        span: 1,
      ),
      if (gamesCard != null)
        StatsCardId.games: _StatsCardEntry(
          id: StatsCardId.games,
          label: l10n.statsGamesLabel,
          widget: gamesCard,
          span: 1,
        ),
      if (recentCard != null)
        StatsCardId.recent: _StatsCardEntry(
          id: StatsCardId.recent,
          label: l10n.statsRecentLabel,
          widget: recentCard,
          span: 1,
        ),
      if (resetsPokemonCard != null)
        StatsCardId.resetsPokemon: _StatsCardEntry(
          id: StatsCardId.resetsPokemon,
          label: l10n.statsResetsPokemonLabel,
          widget: resetsPokemonCard,
          span: 1,
        ),
      if (resetsCard != null)
        StatsCardId.resetsGame: _StatsCardEntry(
          id: StatsCardId.resetsGame,
          label: l10n.statsResetsByGameLabel,
          widget: resetsCard,
          span: 1,
        ),
      if (history != null)
        StatsCardId.history: _StatsCardEntry(
          id: StatsCardId.history,
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

class _StatsMetricCard extends StatelessWidget {
  const _StatsMetricCard({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      title: label,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
        ),
      ),
    );
  }
}

class _StatsCountsChartCard extends StatelessWidget {
  const _StatsCountsChartCard({
    required this.label,
    required this.rangeLabel,
    required this.onPickRange,
    required this.onResetRange,
    required this.counts,
  });

  final String label;
  final String rangeLabel;
  final VoidCallback onPickRange;
  final VoidCallback onResetRange;
  final List<StatsDailyCount> counts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StatsCard(
      title: label,
      titleSpacing: AppSpacing.xs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow =
                  constraints.maxWidth < AppSizes.statsRangeStackWidth;
              final buttonStyle = TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 0,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
              final dateButton = TextButton.icon(
                onPressed: onPickRange,
                style: buttonStyle,
                icon: Icon(Icons.date_range, color: colors.onSurfaceVariant),
                label: Text(
                  rangeLabel,
                  style: AppTypography.listTitle.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.statsRangeTextSize,
                  ),
                ),
              );
              final resetButton = TextButton(
                onPressed: onResetRange,
                style: buttonStyle,
                child: Text(
                  context.l10n.statsRangeReset,
                  style: AppTypography.listTitle.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.statsRangeTextSize,
                  ),
                ),
              );
              final controls = isNarrow
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        dateButton,
                        const SizedBox(height: AppSizes.statsRangeStackGap),
                        resetButton,
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        dateButton,
                        const SizedBox(width: AppSpacing.sm),
                        resetButton,
                      ],
                    );
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  controls,
                  const SizedBox(height: AppSpacing.sm),
                  StatsCountsChart(
                    counts: counts,
                    height: isNarrow
                        ? AppSizes.statsChartHeightCompact
                        : AppSizes.statsChartHeight,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

String _formatRangeLabel(DateTimeRange range) {
  return '${formatDate(range.start)} – ${formatDate(range.end)}';
}

class _StatsGamesCard extends StatefulWidget {
  const _StatsGamesCard({
    required this.label,
    required this.games,
    required this.caughtByGame,
    required this.parentController,
  });

  final String label;
  final List<GameCatchStat> games;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;
  final ScrollController parentController;

  @override
  State<_StatsGamesCard> createState() => _StatsGamesCardState();
}

class _StatsGamesCardState extends State<_StatsGamesCard> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StatsCard(
      title: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: StatsExpandableSection(
              itemCount: widget.games.length,
              foregroundColor: colors.onSurfaceVariant,
              parentController: widget.parentController,
              builder: (visibleCount) {
                final visibleGames = widget.games.take(visibleCount).toList();
                return _StatsGamesTable(
                  games: visibleGames,
                  caughtByGame: widget.caughtByGame,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGamesTable extends StatelessWidget {
  const _StatsGamesTable({required this.games, required this.caughtByGame});

  final List<GameCatchStat> games;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final game in games)
          _StatsGamesRow(
            game: game,
            items: caughtByGame[game.game] ?? const [],
          ),
      ],
    );
  }
}

class _StatsGamesRow extends StatelessWidget {
  const _StatsGamesRow({required this.game, required this.items});

  final GameCatchStat game;
  final List<PokemonCaughtEntry> items;

  @override
  Widget build(BuildContext context) {
    return StatsRow(
      leading: GameLogo(game: game.game, size: AppSizes.statsPokemonImage),
      title: game.game,
      trailing: '${game.count}',
      trailingWidth: AppSizes.statsGameCountWidth,
      maxWidth: AppSizes.statsCaughtGameTableMaxWidth,
      onTap: items.isEmpty
          ? null
          : () => context.goToStatsGame(
              PokemonGameStatsArgs(game: game.game, items: items),
            ),
    );
  }
}

class _StatsRecentCard extends StatefulWidget {
  const _StatsRecentCard({
    required this.label,
    required this.items,
    required this.parentController,
  });

  final String label;
  final List<PokemonCaughtEntry> items;
  final ScrollController parentController;

  @override
  State<_StatsRecentCard> createState() => _StatsRecentCardState();
}

class _StatsRecentCardState extends State<_StatsRecentCard> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StatsCard(
      title: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: StatsExpandableSection(
              itemCount: widget.items.length,
              foregroundColor: colors.onSurfaceVariant,
              parentController: widget.parentController,
              builder: (visibleCount) {
                final visibleItems = widget.items.take(visibleCount).toList();
                return _StatsRecentTable(items: visibleItems);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsResetsCard extends StatelessWidget {
  const _StatsResetsCard({required this.label, required this.resets});

  final String label;
  final List<GameResetStat> resets;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      title: label,
      child: StatsResetsPieChart(resets: resets),
    );
  }
}

class _StatsPokemonResetsCard extends StatelessWidget {
  const _StatsPokemonResetsCard({
    required this.label,
    required this.items,
    required this.parentController,
  });

  final String label;
  final List<PokemonResetStat> items;
  final ScrollController parentController;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StatsCard(
      title: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: StatsExpandableSection(
              itemCount: items.length,
              foregroundColor: colors.onSurfaceVariant,
              parentController: parentController,
              builder: (visibleCount) {
                final visibleItems = items.take(visibleCount).toList();
                return _StatsPokemonResetsTable(items: visibleItems);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRecentTable extends StatelessWidget {
  const _StatsRecentTable({required this.items});

  final List<PokemonCaughtEntry> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final item in items) _StatsRecentRow(item: item)],
    );
  }
}

class _StatsPokemonResetsTable extends StatelessWidget {
  const _StatsPokemonResetsTable({required this.items});

  final List<PokemonResetStat> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final item in items) _StatsPokemonResetsRow(item: item)],
    );
  }
}

class _StatsRecentRow extends StatelessWidget {
  const _StatsRecentRow({required this.item});

  final PokemonCaughtEntry item;

  @override
  Widget build(BuildContext context) {
    return StatsRow(
      leading: PokemonImage(
        path: item.pokemon.imagePath,
        isLocalFile: item.pokemon.isLocalFile,
        width: AppSizes.statsPokemonImage,
        height: AppSizes.statsPokemonImage,
      ),
      title: item.pokemon.name,
      trailing: formatDate(item.caughtAt),
      trailingWidth: AppSizes.statsDateWidth,
      maxWidth: AppSizes.statsRecentCatchTableMaxWidth,
      stackOnNarrow: true,
      onTap: () => context.goToPokemon(item.pokemon),
    );
  }
}

class _StatsPokemonResetsRow extends StatelessWidget {
  const _StatsPokemonResetsRow({required this.item});

  final PokemonResetStat item;

  @override
  Widget build(BuildContext context) {
    return StatsRow(
      leading: PokemonImage(
        path: item.pokemon.imagePath,
        isLocalFile: item.pokemon.isLocalFile,
        width: AppSizes.statsPokemonImage,
        height: AppSizes.statsPokemonImage,
      ),
      title: item.pokemon.name,
      trailing: '${item.count}',
      trailingWidth: AppSizes.statsGameCountWidth,
      maxWidth: AppSizes.statsResetsPokemonTableMaxWidth,
      stackOnNarrow: true,
      onTap: () => context.goToPokemon(item.pokemon),
    );
  }
}

class _StatsCardEntry {
  const _StatsCardEntry({
    required this.id,
    required this.label,
    required this.widget,
    required this.span,
  });

  final StatsCardId id;
  final String label;
  final Widget widget;
  final int span;
}
