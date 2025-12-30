import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class ResponsiveTextRow extends StatelessWidget {
  const ResponsiveTextRow({
    super.key,
    required this.leading,
    required this.title,
    required this.trailing,
    required this.trailingWidth,
    required this.maxWidth,
    required this.stackOnNarrow,
    this.stackThreshold = 1.0,
    this.padding = const EdgeInsets.symmetric(
      vertical: AppSpacing.xs,
      horizontal: AppSpacing.xs,
    ),
    this.titleStyle,
    this.trailingStyle,
  });

  final Widget leading;
  final String title;
  final String trailing;
  final double trailingWidth;
  final double maxWidth;
  final bool stackOnNarrow;
  final double stackThreshold;
  final EdgeInsets padding;
  final TextStyle? titleStyle;
  final TextStyle? trailingStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              stackOnNarrow && constraints.maxWidth < maxWidth * stackThreshold;
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
  }
}
