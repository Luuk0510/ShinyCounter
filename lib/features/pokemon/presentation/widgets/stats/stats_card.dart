import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.child,
    this.padding = AppInsets.card,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}
