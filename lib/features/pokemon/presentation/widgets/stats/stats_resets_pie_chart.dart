import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/game_assets.dart';

class StatsResetsPieChart extends StatelessWidget {
  const StatsResetsPieChart({
    super.key,
    required this.resets,
    this.size = AppSizes.statsChartHeight,
  });

  final List<GameResetStat> resets;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    if (resets.isEmpty) {
      return Center(
        child: Text(
          l10n.statsResetsEmpty,
          textAlign: TextAlign.center,
          style: AppTypography.button.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    final total = resets.fold<int>(0, (sum, entry) => sum + entry.count);
    final palette = _buildPalette(colors, resets.length);
    final sliceColors = _resolveColors(resets, palette);
    final radius = size * AppSizes.statsPieRadiusFactor;
    final centerSpace = size * AppSizes.statsPieCenterSpaceFactor;

    final chart = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SizedBox(
        width: size,
        height: size,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: centerSpace,
            sectionsSpace: AppSizes.statsPieSectionGap,
            startDegreeOffset: -90,
            sections: [
              for (var i = 0; i < resets.length; i++)
                _buildSection(resets[i], total, sliceColors[i], radius),
            ],
          ),
        ),
      ),
    );

    final legend = _LegendList(resets: resets, palette: sliceColors);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppSizes.statsPieLegendMinWidth;
        if (isWide) {
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chart,
                const SizedBox(width: AppSpacing.lg),
                legend,
              ],
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            chart,
            const SizedBox(height: AppSpacing.md),
            legend,
          ],
        );
      },
    );
  }

  PieChartSectionData _buildSection(
    GameResetStat stat,
    int total,
    Color color,
    double radius,
  ) {
    final percent = total == 0 ? 0 : (stat.count / total) * 100;
    final showTitle = percent >= AppSizes.statsPieLabelMinPercent;
    final titleColor = _onSliceColor(color);
    return PieChartSectionData(
      color: color,
      value: stat.count.toDouble(),
      radius: radius,
      title: showTitle ? '${percent.round()}%' : '',
      titleStyle: AppTypography.button.copyWith(
        fontSize: AppSizes.statsRangeTextSize,
        fontWeight: FontWeight.w700,
        color: titleColor,
      ),
      titlePositionPercentageOffset: AppSizes.statsPieLabelOffset,
    );
  }
}

class _LegendList extends StatelessWidget {
  const _LegendList({required this.resets, required this.palette});

  final List<GameResetStat> resets;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < resets.length; i++) {
      rows.add(_LegendRow(stat: resets[i], color: palette[i]));
      if (i != resets.length - 1) {
        rows.add(const SizedBox(height: AppSpacing.xs));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.stat, required this.color});

  final GameResetStat stat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return StatsRow(
      leading: Container(
        width: AppSpacing.sm,
        height: AppSpacing.sm,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: stat.game,
      trailing: '${stat.count}',
      trailingWidth: AppSizes.statsGameCountWidth,
      maxWidth: AppSizes.statsCaughtGameTableMaxWidth,
    );
  }
}

List<Color> _buildPalette(ColorScheme colors, int count) {
  final base = <Color>[
    colors.primary,
    colors.secondary,
    colors.tertiary,
    colors.primaryContainer,
    colors.secondaryContainer,
    colors.tertiaryContainer,
  ];
  if (count <= base.length) {
    return base.take(count).toList();
  }
  final palette = List<Color>.from(base);
  final seed = HSLColor.fromColor(colors.primary);
  final extra = count - base.length;
  final step = 360.0 / (extra + 1);
  for (var i = 0; i < extra; i++) {
    final hue = (seed.hue + step * (i + 1)) % 360;
    final lightness = (seed.lightness * 0.9).clamp(0.35, 0.7);
    final saturation = (seed.saturation * 0.85).clamp(0.35, 0.9);
    palette.add(
      seed
          .withHue(hue)
          .withLightness(lightness)
          .withSaturation(saturation)
          .toColor(),
    );
  }
  return palette;
}

Color _onSliceColor(Color color) {
  final brightness = ThemeData.estimateBrightnessForColor(color);
  return brightness == Brightness.dark ? Colors.white : Colors.black;
}

List<Color> _resolveColors(List<GameResetStat> resets, List<Color> palette) {
  final colors = <Color>[];
  var paletteIndex = 0;
  for (final stat in resets) {
    final custom = GameAssets.colorFor(stat.game);
    if (custom != null) {
      colors.add(custom);
      continue;
    }
    colors.add(palette[paletteIndex % palette.length]);
    paletteIndex++;
  }
  return colors;
}
