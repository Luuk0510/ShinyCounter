import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

class StatsCountsChart extends StatefulWidget {
  const StatsCountsChart({
    super.key,
    required this.counts,
    this.height = AppSizes.statsChartHeight,
  });

  final List<StatsDailyCount> counts;
  final double height;

  @override
  State<StatsCountsChart> createState() => _StatsCountsChartState();
}

class _StatsCountsChartState extends State<StatsCountsChart> {
  int? _tooltipIndex;
  Offset? _tooltipPosition;
  bool _tooltipVisible = false;

  void _handleTouch(FlTouchEvent event, LineTouchResponse? response) {
    final spots = response?.lineBarSpots;
    if (!event.isInterestedForInteractions ||
        spots == null ||
        spots.isEmpty ||
        event.localPosition == null) {
      if (_tooltipVisible) {
        setState(() {
          _tooltipVisible = false;
        });
      }
      return;
    }
    final index = spots.first.spotIndex;
    if (index < 0 || index >= widget.counts.length) return;
    setState(() {
      _tooltipIndex = index;
      _tooltipPosition = event.localPosition;
      _tooltipVisible = true;
    });
  }

  Offset _clampTooltipOffset(Offset position, Size size) {
    final tooltipWidth = AppSizes.statsChartTooltipWidth;
    final tooltipHeight = AppSizes.statsChartTooltipHeight;
    final padding = AppSpacing.sm;
    final maxLeft = math.max(padding, size.width - tooltipWidth - padding);
    final maxTop = math.max(padding, size.height - tooltipHeight - padding);
    final left = (position.dx - tooltipWidth / 2).clamp(padding, maxLeft);
    final top = (position.dy - tooltipHeight - padding).clamp(padding, maxTop);
    return Offset(left.toDouble(), top.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final counts = widget.counts;
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
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final tooltipOffset = _tooltipPosition == null
              ? const Offset(0, 0)
              : _clampTooltipOffset(_tooltipPosition!, size);
          final touchThreshold = math.max(constraints.maxWidth, 1.0).toDouble();
          return Stack(
            children: [
              LineChart(
                LineChartData(
                  minY: 0,
                  maxY: axisMax,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colors.outlineVariant.withValues(alpha: 0.18),
                      strokeWidth: 1,
                    ),
                  ),
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
                          return Text(
                            ticks[index].toString(),
                            style: labelStyle,
                          );
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
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            fitInside: SideTitleFitInsideData.fromTitleMeta(
                              meta,
                              distanceFromEdge: AppSpacing.xs,
                            ),
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
                      barWidth: AppSizes.statsChartStroke + 1,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppButtonPalette.primaryFill(
                          colors,
                        ).withValues(alpha: 0.22),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchCallback: _handleTouch,
                    touchSpotThreshold: touchThreshold,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) =>
                          List<LineTooltipItem?>.filled(
                            touchedSpots.length,
                            null,
                          ),
                    ),
                  ),
                ),
                duration: AppAnim.normal,
                curve: AppAnim.easeOutCubic,
              ),
              Positioned(
                left: tooltipOffset.dx,
                top: tooltipOffset.dy,
                child: AnimatedSwitcher(
                  duration: AppAnim.normal,
                  switchInCurve: AppAnim.easeOutCubic,
                  switchOutCurve: AppAnim.easeOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.96,
                        end: 1.0,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: !_tooltipVisible || _tooltipIndex == null
                      ? const SizedBox.shrink()
                      : _StatsChartTooltip(
                          key: ValueKey<int>(_tooltipIndex!),
                          entry: counts[_tooltipIndex!],
                          colors: colors,
                          background: theme.cardColor,
                        ),
                ),
              ),
            ],
          );
        },
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
}

class _StatsChartTooltip extends StatelessWidget {
  const _StatsChartTooltip({
    super.key,
    required this.entry,
    required this.colors,
    required this.background,
  });

  final StatsDailyCount entry;
  final ColorScheme colors;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: AppSizes.statsChartTooltipWidth,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: colors.onSurface),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.count}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  formatDate(entry.date),
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
