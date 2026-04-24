import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class CollapsibleSection extends StatelessWidget {
  const CollapsibleSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.headerPadding = const EdgeInsets.fromLTRB(
      AppSizes.cardPaddingH,
      AppSpacing.xxs,
      AppSizes.cardPaddingH,
      AppSpacing.xxs,
    ),
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final EdgeInsets headerPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: headerPadding,
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppTypography.sectionTitle)),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: AppAnim.normal,
                  curve: AppAnim.easeOut,
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: AppAnim.normal,
          switchInCurve: AppAnim.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return ClipRect(
              child: SizeTransition(
                axis: Axis.vertical,
                axisAlignment: -1,
                sizeFactor: animation,
                child: child,
              ),
            );
          },
          child: expanded ? child : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
