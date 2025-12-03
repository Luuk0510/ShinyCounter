import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class HuntInfoCard extends StatelessWidget {
  const HuntInfoCard({
    super.key,
    required this.colors,
    required this.startedAt,
    required this.caughtAt,
    required this.caughtGame,
    required this.formatter,
  });

  final ColorScheme colors;
  final DateTime? startedAt;
  final DateTime? caughtAt;
  final String? caughtGame;
  final String Function(DateTime?) formatter;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
    final valueStyle = TextStyle(
      color: colors.onSurface,
      fontSize: 17,
      fontWeight: FontWeight.w800,
    );
    final cardColor = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HuntCell(
                label: 'Start',
                value: formatter(startedAt),
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
              const SizedBox(width: AppSpacing.md),
              _HuntCell(
                label: 'Catch',
                value: formatter(caughtAt),
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
            ],
          ),
          if (caughtGame != null && caughtGame!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'Pokemon $caughtGame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HuntCell extends StatelessWidget {
  const _HuntCell({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: valueStyle),
      ],
    );
  }
}
