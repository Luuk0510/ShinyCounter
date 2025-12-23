import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

class StatsCountsChart extends StatelessWidget {
  const StatsCountsChart({super.key, required this.counts});

  final List<StatsDailyCount> counts;

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final maxValue = counts
        .map((entry) => entry.count)
        .fold<int>(0, (max, value) => value > max ? value : max);
    final ticks = _buildTicks(maxValue);
    final axisMax = ticks.length <= 1 ? 1.0 : (ticks.length - 1).toDouble();
    final spots = [
      for (var i = 0; i < counts.length; i++)
        FlSpot(i.toDouble(), _mapToAxis(counts[i].count, ticks)),
    ];
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant);
    return SizedBox(
      height: AppSizes.statsChartHeight,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: axisMax,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if ((value - index).abs() > 0.001) {
                    return const SizedBox.shrink();
                  }
                  if (index < 0 || index >= ticks.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(ticks[index].toString(), style: labelStyle);
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: counts.length > 1 ? counts.length - 1 : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= counts.length) {
                    return const SizedBox.shrink();
                  }
                  final date = counts[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(formatDate(date), style: labelStyle),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppButtonPalette.primaryFill(colors),
              barWidth: AppSizes.statsChartStroke,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppButtonPalette.primaryFill(colors).withValues(
                  alpha: 0.16,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: AppRadii.sm,
              tooltipBorder: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.3),
              ),
              getTooltipColor: (_) => theme.cardColor,
              getTooltipItems: (touchedSpots) {
                return [
                  for (final spot in touchedSpots)
                    _buildTooltipItem(spot, counts, colors),
                ];
              },
            ),
          ),
        ),
      ),
    );
  }

  List<int> _buildTicks(int maxValue) {
    final ticks = <int>[0, 50, 100, 200, 300, 400, 500];
    ticks.retainWhere((value) => value <= maxValue);
    if (maxValue > 0 && !ticks.contains(maxValue)) {
      ticks.add(maxValue);
    }
    if (ticks.isEmpty) {
      ticks.add(0);
    }
    ticks.sort();
    return ticks;
  }

  double _mapToAxis(int value, List<int> ticks) {
    if (ticks.length <= 1) return 0;
    for (var i = 0; i < ticks.length - 1; i++) {
      final start = ticks[i];
      final end = ticks[i + 1];
      if (value <= end) {
        final range = (end - start);
        final progress = range == 0 ? 0.0 : (value - start) / range;
        return i + progress;
      }
    }
    return (ticks.length - 1).toDouble();
  }

  LineTooltipItem _buildTooltipItem(
    LineBarSpot spot,
    List<StatsDailyCount> counts,
    ColorScheme colors,
  ) {
    final index = spot.x.round();
    if (index < 0 || index >= counts.length) {
      return const LineTooltipItem('', TextStyle());
    }
    final entry = counts[index];
    final dateStyle = TextStyle(color: colors.onSurfaceVariant);
    final countStyle = TextStyle(
      color: colors.onSurface,
      fontWeight: FontWeight.w700,
    );
    return LineTooltipItem(
      '${entry.count}',
      countStyle,
      children: [
        TextSpan(text: '\n${formatDate(entry.date)}', style: dateStyle),
      ],
    );
  }
}
