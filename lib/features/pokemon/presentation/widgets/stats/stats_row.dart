import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/responsive_text_row.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.leading,
    required this.title,
    required this.trailing,
    required this.trailingWidth,
    required this.maxWidth,
    this.onTap,
    this.stackOnNarrow = false,
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
  final bool stackOnNarrow;
  final EdgeInsets padding;
  final double borderRadius;
  final bool useMaterial;
  final TextStyle? titleStyle;
  final TextStyle? trailingStyle;

  @override
  Widget build(BuildContext context) {
    Widget content = ResponsiveTextRow(
      leading: leading,
      title: title,
      trailing: trailing,
      trailingWidth: trailingWidth,
      maxWidth: maxWidth,
      stackOnNarrow: stackOnNarrow,
      stackThreshold: 0.7,
      padding: padding,
      titleStyle: titleStyle,
      trailingStyle: trailingStyle,
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
