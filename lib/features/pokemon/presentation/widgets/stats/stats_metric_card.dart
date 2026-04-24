import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_counts_chart.dart';

class StatsMetricCard extends StatelessWidget {
  const StatsMetricCard({
    super.key,
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

class StatsCountsChartCard extends StatelessWidget {
  const StatsCountsChartCard({
    super.key,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < AppSizes.statsRangeStackWidth;
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
    );
  }
}
