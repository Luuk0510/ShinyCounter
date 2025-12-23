import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_app_bar.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_counts_chart.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

class PokemonStatsPage extends StatefulWidget {
  const PokemonStatsPage({super.key});

  @override
  State<PokemonStatsPage> createState() => _PokemonStatsPageState();
}

class _PokemonStatsPageState extends State<PokemonStatsPage> {
  static const int _defaultChartDays = 30;

  late final LoadCustomPokemonUseCase _loadCustomPokemon;
  late final LoadCaughtUseCase _loadCaught;
  late final CounterSync _sync;
  late DateTimeRange _chartRange;
  List<CounterState> _states = const [];
  bool _loading = true;
  StatsSummary _summary = const StatsSummary.empty();

  @override
  void initState() {
    super.initState();
    _loadCustomPokemon = context.read<LoadCustomPokemonUseCase>();
    _loadCaught = context.read<LoadCaughtUseCase>();
    _sync = context.read<CounterSync>();
    _chartRange = _defaultChartRange();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final pokemon = await _loadCustomPokemon();
    final caught = await _loadCaught(pokemon);
    final states = await Future.wait(
      pokemon.map((p) {
        final keys = CounterKeys.fromId(p.id);
        return _sync.loadState(keys.counter, keys.caught);
      }),
    );
    final totalCounts = states.fold<int>(0, (sum, state) => sum + state.count);
    final caughtByGame = <String, int>{};
    final caughtEntriesByGame = <String, List<PokemonCaughtEntry>>{};
    final recentCaught = <PokemonCaughtEntry>[];
    final dailyTotals = _buildDailyTotals(states, _chartRange);
    for (var i = 0; i < states.length; i++) {
      final state = states[i];
      if (!state.isCaught) continue;
      final game = state.caughtGame;
      if (game != null && game.isNotEmpty) {
        caughtByGame.update(game, (value) => value + 1, ifAbsent: () => 1);
        caughtEntriesByGame
            .putIfAbsent(game, () => [])
            .add(PokemonCaughtEntry(pokemon[i], state.caughtAt));
      }
      final caughtAt = state.caughtAt;
      if (caughtAt == null) continue;
      recentCaught.add(PokemonCaughtEntry(pokemon[i], caughtAt));
    }
    final caughtGames =
        caughtByGame.entries
            .map((entry) => GameCatchStat(entry.key, entry.value))
            .toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            return byCount != 0 ? byCount : a.game.compareTo(b.game);
          });
    for (final entries in caughtEntriesByGame.values) {
      entries.sort((a, b) {
        final left = a.caughtAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.caughtAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
    }
    recentCaught.sort((a, b) => b.caughtAt!.compareTo(a.caughtAt!));
    if (!mounted) return;
    setState(() {
      _states = states;
      _summary = StatsSummary(
        totalPokemon: pokemon.length,
        caughtPokemon: caught.length,
        totalCounts: totalCounts,
        dailyTotals: dailyTotals,
        caughtGames: caughtGames,
        caughtByGame: caughtEntriesByGame,
        recentCaught: recentCaught,
      );
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
      _summary = _summary.copyWith(
        dailyTotals: _buildDailyTotals(_states, range),
      );
    });
  }

  void _resetChartRange() {
    final range = _defaultChartRange();
    setState(() {
      _chartRange = range;
      _summary = _summary.copyWith(
        dailyTotals: _buildDailyTotals(_states, range),
      );
    });
  }

  List<StatsDailyCount> _buildDailyTotals(
    List<CounterState> states,
    DateTimeRange range,
  ) {
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    final totals = <DateTime, int>{};
    final days = end.difference(start).inDays;
    for (var i = 0; i <= days; i++) {
      final day = start.add(Duration(days: i));
      totals[day] = 0;
    }
    for (final state in states) {
      if (state.dailyCounts.isEmpty) continue;
      for (final entry in state.dailyCounts.entries) {
        final parsed = DateTime.tryParse(entry.key);
        if (parsed == null) continue;
        final day = DateTime(parsed.year, parsed.month, parsed.day);
        if (day.isBefore(start) || day.isAfter(end)) continue;
        totals.update(day, (value) => value + entry.value, ifAbsent: () => 0);
      }
    }
    final sortedDays = totals.keys.toList()..sort();
    return [
      for (final day in sortedDays)
        StatsDailyCount(date: day, count: totals[day] ?? 0),
    ];
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

                final viewInset = MediaQuery.of(context).viewPadding.bottom;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.xl + viewInset,
                  ),
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
                    if (gamesCard != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      gamesCard,
                    ],
                    if (recentCard != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      recentCard,
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

class StatsSummary {
  const StatsSummary({
    required this.totalPokemon,
    required this.caughtPokemon,
    required this.totalCounts,
    required this.dailyTotals,
    required this.caughtGames,
    required this.caughtByGame,
    required this.recentCaught,
  });

  const StatsSummary.empty()
    : totalPokemon = 0,
      caughtPokemon = 0,
      totalCounts = 0,
      dailyTotals = const <StatsDailyCount>[],
      caughtGames = const <GameCatchStat>[],
      caughtByGame = const <String, List<PokemonCaughtEntry>>{},
      recentCaught = const <PokemonCaughtEntry>[];

  final int totalPokemon;
  final int caughtPokemon;
  final int totalCounts;
  final List<StatsDailyCount> dailyTotals;
  final List<GameCatchStat> caughtGames;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;
  final List<PokemonCaughtEntry> recentCaught;

  StatsSummary copyWith({
    int? totalPokemon,
    int? caughtPokemon,
    int? totalCounts,
    List<StatsDailyCount>? dailyTotals,
    List<GameCatchStat>? caughtGames,
    Map<String, List<PokemonCaughtEntry>>? caughtByGame,
    List<PokemonCaughtEntry>? recentCaught,
  }) {
    return StatsSummary(
      totalPokemon: totalPokemon ?? this.totalPokemon,
      caughtPokemon: caughtPokemon ?? this.caughtPokemon,
      totalCounts: totalCounts ?? this.totalCounts,
      dailyTotals: dailyTotals ?? this.dailyTotals,
      caughtGames: caughtGames ?? this.caughtGames,
      caughtByGame: caughtByGame ?? this.caughtByGame,
      recentCaught: recentCaught ?? this.recentCaught,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: onPickRange,
                icon: Icon(Icons.date_range, color: colors.onSurfaceVariant),
                label: Text(
                  rangeLabel,
                  style: AppTypography.listTitle.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.statsRangeTextSize,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onResetRange,
                child: Text(
                  context.l10n.statsRangeReset,
                  style: AppTypography.listTitle.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.statsRangeTextSize,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          StatsCountsChart(counts: counts),
        ],
      ),
    );
  }
}

String _formatRangeLabel(DateTimeRange range) {
  return '${formatDate(range.start)} – ${formatDate(range.end)}';
}

class GameCatchStat {
  const GameCatchStat(this.game, this.count);

  final String game;
  final int count;
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
      leading: GameLogo(game: game.game, size: AppSizes.gameLogoSize),
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
