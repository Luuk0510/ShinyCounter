import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class StatsExpandableSection extends StatefulWidget {
  const StatsExpandableSection({
    super.key,
    required this.itemCount,
    required this.builder,
    this.initialVisible = 3,
    this.maxExpandedVisible = AppSizes.statsExpandableMaxVisible,
    this.foregroundColor,
    this.parentController,
  });

  final int itemCount;
  final int initialVisible;
  final int maxExpandedVisible;
  final Color? foregroundColor;
  final ScrollController? parentController;
  final Widget Function(int visibleCount) builder;

  @override
  State<StatsExpandableSection> createState() => _StatsExpandableSectionState();
}

class _StatsExpandableSectionState extends State<StatsExpandableSection> {
  bool _expanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasOverflow = widget.itemCount > widget.initialVisible;
    final visibleCount = _expanded || !hasOverflow
        ? widget.itemCount
        : widget.initialVisible;
    final needsScroll =
        _expanded && widget.itemCount > widget.maxExpandedVisible;
    final foreground =
        widget.foregroundColor ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    final parentController =
        widget.parentController ?? PrimaryScrollController.maybeOf(context);
    final content = widget.builder(visibleCount);
    final maxHeight =
        AppSizes.statsExpandableRowHeight * widget.maxExpandedVisible;
    final body = needsScroll
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              interactive: true,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is OverscrollNotification &&
                      parentController != null &&
                      parentController.hasClients) {
                    final parentPosition = parentController.position;
                    final target =
                        (parentPosition.pixels + notification.overscroll).clamp(
                          parentPosition.minScrollExtent,
                          parentPosition.maxScrollExtent,
                        );
                    parentController.jumpTo(target);
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: content,
                ),
              ),
            ),
          )
        : content;

    return Column(
      children: [
        AnimatedSize(
          duration: AppAnim.normal,
          curve: AppAnim.easeOutCubic,
          alignment: Alignment.topCenter,
          child: body,
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
