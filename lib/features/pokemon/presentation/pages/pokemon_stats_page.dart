import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
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
    final totalCounts = states.fold<int>(
      0,
      (sum, state) => sum + state.count,
    );
    if (!mounted) return;
    setState(() {
      _summary = StatsSummary(
        totalPokemon: pokemon.length,
        caughtPokemon: caught.length,
        totalCounts: totalCounts,
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
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              children: [
                _StatsSection(
                  title: l10n.statsCaughtLabel,
                  child: _StatsMetricCard(
                    label: l10n.statsCaughtLabel,
                    value:
                        '${_summary.caughtPokemon} / ${_summary.totalPokemon}',
                    colors: colors,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatsSection(
                  title: l10n.statsTotalCountsLabel,
                  child: _StatsMetricCard(
                    label: l10n.statsTotalCountsLabel,
                    value: '${_summary.totalCounts}',
                    colors: colors,
                  ),
                ),
              ],
            ),
    );
  }
}

class StatsSummary {
  const StatsSummary({
    required this.totalPokemon,
    required this.caughtPokemon,
    required this.totalCounts,
  });

  const StatsSummary.empty()
    : totalPokemon = 0,
      caughtPokemon = 0,
      totalCounts = 0;

  final int totalPokemon;
  final int caughtPokemon;
  final int totalCounts;
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

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.sectionTitle.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.button.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
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
