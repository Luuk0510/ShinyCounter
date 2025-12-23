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
    Widget content = Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = stackOnNarrow && constraints.maxWidth < maxWidth * 0.7;
          if (isCompact) {
            return Row(
              children: [
                leading,
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: titleStyle,
                            maxLines: 1,
                            softWrap: false,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            trailing,
                            style: trailingStyle,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: titleStyle,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: trailingWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      trailing,
                      style: trailingStyle,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
