import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class StatsExpandableSection extends StatefulWidget {
  const StatsExpandableSection({
    super.key,
    required this.itemCount,
    required this.builder,
    this.initialVisible = 3,
    this.foregroundColor,
  });

  final int itemCount;
  final int initialVisible;
  final Color? foregroundColor;
  final Widget Function(int visibleCount) builder;

  @override
  State<StatsExpandableSection> createState() => _StatsExpandableSectionState();
}

class _StatsExpandableSectionState extends State<StatsExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasOverflow = widget.itemCount > widget.initialVisible;
    final visibleCount = _expanded || !hasOverflow
        ? widget.itemCount
        : widget.initialVisible;
    final foreground =
        widget.foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      children: [
        AnimatedSize(
          duration: AppAnim.normal,
          curve: AppAnim.easeOutCubic,
          alignment: Alignment.topCenter,
          child: widget.builder(visibleCount),
        ),
        if (hasOverflow) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(foregroundColor: foreground),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded ? l10n.statsGamesShowLess : l10n.statsGamesShowMore,
                ),
                const SizedBox(width: AppSpacing.xs),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: AppAnim.normal,
                  curve: AppAnim.easeOutCubic,
                  child: const Icon(Icons.expand_more, size: 18),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
