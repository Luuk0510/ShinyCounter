import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_app_bar.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_counts_chart.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_resets_pie_chart.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/domain/services/stats_aggregation_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

class PokemonStatsPage extends StatefulWidget {
  const PokemonStatsPage({super.key});

  @override
  State<PokemonStatsPage> createState() => _PokemonStatsPageState();
}

class _PokemonStatsPageState extends State<PokemonStatsPage> {
  static const int _defaultChartDays = 30;

  late final StatsAggregationService _statsService;
  late DateTimeRange _chartRange;
  List<CounterState> _states = const [];
  bool _loading = true;
  StatsSummary _summary = const StatsSummary.empty();

  @override
  void initState() {
    super.initState();
    _statsService = StatsAggregationService(
      repository: context.read<StatsRepository>(),
    );
    _chartRange = _defaultChartRange();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final snapshot = await _statsService.loadStats(_chartRange);
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
      _summary = _statsService.updateSummaryForRange(_summary, _states, range);
    });
  }

  void _resetChartRange() {
    final range = _defaultChartRange();
    setState(() {
      _chartRange = range;
      _summary = _statsService.updateSummaryForRange(_summary, _states, range);
    });
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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                final caught = _StatsMetricCard(
                  label: l10n.statsCaughtLabel,
                  value: '${_summary.caughtPokemon} / ${_summary.totalPokemon}',
                  colors: colors,
                );
                final total = _StatsMetricCard(
                  label: l10n.statsTotalCountsLabel,
                  value: '${_summary.totalCounts}',
                  colors: colors,
                );
                final history = _summary.dailyTotals.isEmpty
                    ? null
                    : _StatsCountsChartCard(
                        label: l10n.huntHistoryTitle,
                        rangeLabel: _formatRangeLabel(_chartRange),
                        onPickRange: _pickChartRange,
                        onResetRange: _resetChartRange,
                        counts: _summary.dailyTotals,
                      );

                final gamesCard = _summary.caughtGames.isEmpty
                    ? null
                    : _StatsGamesCard(
                        label: l10n.statsGamesLabel,
                        games: _summary.caughtGames,
                        caughtByGame: _summary.caughtByGame,
                      );
                final recentCard = _summary.recentCaught.isEmpty
                    ? null
                    : _StatsRecentCard(
                        label: l10n.statsRecentLabel,
                        items: _summary.recentCaught,
                      );
                final resetsPokemonCard = _summary.resetsByPokemon.isEmpty
                    ? null
                    : _StatsPokemonResetsCard(
                        label: l10n.statsResetsPokemonLabel,
                        items: _summary.resetsByPokemon,
                      );
                final resetsCard = _summary.resetsByGame.isEmpty
                    ? null
                    : _StatsResetsCard(
                        label: l10n.statsResetsByGameLabel,
                        resets: _summary.resetsByGame,
                      );
                final showSideBySide =
                    isWide && gamesCard != null && recentCard != null;
                final showResetsSideBySide =
                    isWide && resetsPokemonCard != null && resetsCard != null;

                final viewInset = MediaQuery.of(context).viewPadding.bottom;
                return ListView(
                  padding: AppInsets.pageWithBottomInset(viewInset),
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: caught),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: total),
                        ],
                      )
                    else ...[
                      caught,
                      const SizedBox(height: AppSpacing.lg),
                      total,
                    ],
                    if (showSideBySide) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: gamesCard),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: recentCard),
                        ],
                      ),
                    ] else ...[
                      if (gamesCard != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        gamesCard,
                      ],
                      if (recentCard != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        recentCard,
                      ],
                    ],
                    if (showResetsSideBySide) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: resetsPokemonCard),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: resetsCard),
                        ],
                      ),
                    ] else ...[
                      if (resetsPokemonCard != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        resetsPokemonCard,
                      ],
                      if (resetsCard != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        resetsCard,
                      ],
                    ],
                    if (history != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      history,
                    ],
                  ],
                );
              },
            ),
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
  });

  final String label;
  final List<GameCatchStat> games;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;

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
  const _StatsRecentCard({required this.label, required this.items});

  final String label;
  final List<PokemonCaughtEntry> items;

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
  const _StatsPokemonResetsCard({required this.label, required this.items});

  final String label;
  final List<PokemonResetStat> items;

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
