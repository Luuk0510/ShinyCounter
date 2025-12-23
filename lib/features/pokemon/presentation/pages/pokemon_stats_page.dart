import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

class PokemonStatsPage extends StatefulWidget {
  const PokemonStatsPage({super.key});

  @override
  State<PokemonStatsPage> createState() => _PokemonStatsPageState();
}

class _PokemonStatsPageState extends State<PokemonStatsPage> {
  late final LoadCustomPokemonUseCase _loadCustomPokemon;
  late final LoadCaughtUseCase _loadCaught;
  late final CounterSync _sync;
  bool _loading = true;
  StatsSummary _summary = const StatsSummary.empty();

  @override
  void initState() {
    super.initState();
    _loadCustomPokemon = context.read<LoadCustomPokemonUseCase>();
    _loadCaught = context.read<LoadCaughtUseCase>();
    _sync = context.read<CounterSync>();
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
    for (final state in states) {
      final game = state.caughtGame;
      if (!state.isCaught || game == null || game.isEmpty) continue;
      caughtByGame.update(game, (value) => value + 1, ifAbsent: () => 1);
    }
    final caughtGames =
        caughtByGame.entries
            .map((entry) => GameCatchStat(entry.key, entry.value))
            .toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            return byCount != 0 ? byCount : a.game.compareTo(b.game);
          });
    if (!mounted) return;
    setState(() {
      _summary = StatsSummary(
        totalPokemon: pokemon.length,
        caughtPokemon: caught.length,
        totalCounts: totalCounts,
        caughtGames: caughtGames,
      );
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: _StatsAppBar(title: l10n.statsTitle),
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

                final gamesCard = _summary.caughtGames.isEmpty
                    ? null
                    : _StatsGamesCard(
                        label: l10n.statsGamesLabel,
                        games: _summary.caughtGames,
                      );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.xl,
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
    required this.caughtGames,
  });

  const StatsSummary.empty()
    : totalPokemon = 0,
      caughtPokemon = 0,
      totalCounts = 0,
      caughtGames = const <GameCatchStat>[];

  final int totalPokemon;
  final int caughtPokemon;
  final int totalCounts;
  final List<GameCatchStat> caughtGames;
}

class _StatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _StatsAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: AppSizes.toolbarHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(size: AppSizes.appBarActionIcon),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.lg),
        ),
      ),
      flexibleSpace: Builder(
        builder: (context) {
          final scopedCard = Theme.of(context).cardColor;
          return Container(
            decoration: BoxDecoration(
              color: scopedCard,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.lg),
              ),
            ),
          );
        },
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.merge(
          AppTypography.title.copyWith(fontWeight: FontWeight.w700),
        ),
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
    return Container(
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.button.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class GameCatchStat {
  const GameCatchStat(this.game, this.count);

  final String game;
  final int count;
}

class _StatsGamesCard extends StatefulWidget {
  const _StatsGamesCard({required this.label, required this.games});

  final String label;
  final List<GameCatchStat> games;

  @override
  State<_StatsGamesCard> createState() => _StatsGamesCardState();
}

class _StatsGamesCardState extends State<_StatsGamesCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final hasOverflow = widget.games.length > 3;
    final visibleGames = _expanded || !hasOverflow
        ? widget.games
        : widget.games.take(3).toList();

    return Container(
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppTypography.button.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.center,
            child: AnimatedSize(
              duration: AppAnim.normal,
              curve: AppAnim.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _StatsGamesTable(games: visibleGames, colors: colors),
            ),
          ),
          if (hasOverflow) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                foregroundColor: colors.onSurfaceVariant,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded
                        ? l10n.statsGamesShowLess
                        : l10n.statsGamesShowMore,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: AppAnim.normal,
                    curve: AppAnim.easeOutCubic,
                    child: const Icon(Icons.expand_more, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsGamesTable extends StatelessWidget {
  const _StatsGamesTable({required this.games, required this.colors});

  final List<GameCatchStat> games;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
      },
      children: [
        for (final game in games)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GameLogo(game: game.game, size: AppSizes.gameLogoSize),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      game.game,
                      style: AppTypography.listTitle.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${game.count}',
                    style: AppTypography.listTitle.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
