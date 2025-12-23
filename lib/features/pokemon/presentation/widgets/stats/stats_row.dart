import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.leading,
    required this.title,
    required this.trailing,
    required this.trailingWidth,
    required this.maxWidth,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      vertical: AppSpacing.xs,
      horizontal: AppSpacing.xs,
    ),
    this.borderRadius = AppRadii.sm,
    this.useMaterial = true,
    this.titleStyle,
    this.trailingStyle,
  });

  final Widget leading;
  final String title;
  final String trailing;
  final double trailingWidth;
  final VoidCallback? onTap;
  final double maxWidth;
  final EdgeInsets padding;
  final double borderRadius;
  final bool useMaterial;
  final TextStyle? titleStyle;
  final TextStyle? trailingStyle;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(title, style: titleStyle)),
          SizedBox(
            width: trailingWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(trailing, style: trailingStyle),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    if (useMaterial) {
      content = Material(type: MaterialType.transparency, child: content);
    }

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}
