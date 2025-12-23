import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_app_bar.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_game_stats_page.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';
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
    final caughtEntriesByGame = <String, List<PokemonCaughtEntry>>{};
    final recentCaught = <PokemonCaughtEntry>[];
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
      _summary = StatsSummary(
        totalPokemon: pokemon.length,
        caughtPokemon: caught.length,
        totalCounts: totalCounts,
        caughtGames: caughtGames,
        caughtByGame: caughtEntriesByGame,
        recentCaught: recentCaught,
      );
      _loading = false;
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
    required this.caughtByGame,
    required this.recentCaught,
  });

  const StatsSummary.empty()
    : totalPokemon = 0,
      caughtPokemon = 0,
      totalCounts = 0,
      caughtGames = const <GameCatchStat>[],
      caughtByGame = const <String, List<PokemonCaughtEntry>>{},
      recentCaught = const <PokemonCaughtEntry>[];

  final int totalPokemon;
  final int caughtPokemon;
  final int totalCounts;
  final List<GameCatchStat> caughtGames;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;
  final List<PokemonCaughtEntry> recentCaught;
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
            child: Material(
              type: MaterialType.transparency,
              child: AnimatedSize(
                duration: AppAnim.normal,
                curve: AppAnim.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _StatsGamesTable(
                  games: visibleGames,
                  colors: colors,
                  caughtByGame: widget.caughtByGame,
                ),
              ),
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
  const _StatsGamesTable({
    required this.games,
    required this.colors,
    required this.caughtByGame,
  });

  final List<GameCatchStat> games;
  final ColorScheme colors;
  final Map<String, List<PokemonCaughtEntry>> caughtByGame;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final game in games)
          _StatsGamesRow(
            game: game,
            colors: colors,
            items: caughtByGame[game.game] ?? const [],
          ),
      ],
    );
  }
}

class _StatsGamesRow extends StatelessWidget {
  const _StatsGamesRow({
    required this.game,
    required this.colors,
    required this.items,
  });

  final GameCatchStat game;
  final ColorScheme colors;
  final List<PokemonCaughtEntry> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.statsCaughtGameTableMaxWidth,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: items.isEmpty
                  ? null
                  : () => context.goToStatsGame(
                      PokemonGameStatsArgs(game: game.game, items: items),
                    ),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Row(
                  children: [
                    GameLogo(game: game.game, size: AppSizes.gameLogoSize),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        game.game,
                        style: AppTypography.listTitle.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSizes.statsGameCountWidth,
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
              ),
            ),
          ),
        ),
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
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final hasOverflow = widget.items.length > 3;
    final visibleItems = _expanded || !hasOverflow
        ? widget.items
        : widget.items.take(3).toList();

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
              child: _StatsRecentTable(items: visibleItems, colors: colors),
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

class _StatsRecentTable extends StatelessWidget {
  const _StatsRecentTable({required this.items, required this.colors});

  final List<PokemonCaughtEntry> items;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) _StatsRecentRow(item: item, colors: colors),
      ],
    );
  }
}

class _StatsRecentRow extends StatelessWidget {
  const _StatsRecentRow({required this.item, required this.colors});

  final PokemonCaughtEntry item;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.statsRecentCatchTableMaxWidth,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => context.goToPokemon(item.pokemon),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Row(
                  children: [
                    PokemonImage(
                      path: item.pokemon.imagePath,
                      isLocalFile: item.pokemon.isLocalFile,
                      width: AppSizes.statsPokemonImage,
                      height: AppSizes.statsPokemonImage,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.pokemon.name,
                        style: AppTypography.listTitle.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSizes.statsDateWidth,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatDate(item.caughtAt),
                          style: AppTypography.listTitle.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
