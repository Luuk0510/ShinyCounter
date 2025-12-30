import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.child,
    this.padding = AppInsets.card,
    this.title,
    this.titleStyle,
    this.titleSpacing = AppSpacing.sm,
  });

  final Widget child;
  final EdgeInsets padding;
  final String? title;
  final TextStyle? titleStyle;
  final double titleSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedTitleStyle =
        titleStyle ??
        AppTypography.button.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        );
    final content = title == null
        ? child
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title!,
                textAlign: TextAlign.center,
                style: resolvedTitleStyle,
              ),
              SizedBox(height: titleSpacing),
              child,
            ],
          );
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: content,
    );
  }
}
