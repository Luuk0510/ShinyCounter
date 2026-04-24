import 'package:flutter/material.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_section.dart';

class StatsExpandableListCard<T> extends StatelessWidget {
  const StatsExpandableListCard({
    super.key,
    required this.title,
    required this.items,
    required this.parentController,
    required this.itemBuilder,
  });

  final String title;
  final List<T> items;
  final ScrollController parentController;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StatsCard(
      title: title,
      child: Align(
        alignment: Alignment.center,
        child: StatsExpandableSection(
          itemCount: items.length,
          foregroundColor: colors.onSurfaceVariant,
          parentController: parentController,
          builder: (visibleCount) {
            return Column(
              children: [
                for (final item in items.take(visibleCount))
                  itemBuilder(context, item),
              ],
            );
          },
        ),
      ),
    );
  }
}
