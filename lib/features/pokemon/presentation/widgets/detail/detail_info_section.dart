import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/counter_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/formatters.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail/count_info_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail/counter_controls.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail/daily_counts_list.dart';

class DetailInfoSection extends StatelessWidget {
  const DetailInfoSection({
    super.key,
    required this.colors,
    required this.controller,
    required this.onEdit,
    required this.onDailyCounts,
    required this.onGameChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ColorScheme colors;
  final CounterController controller;
  final VoidCallback onEdit;
  final VoidCallback onDailyCounts;
  final ValueChanged<String?> onGameChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CounterControls(
            count: controller.counter,
            enabled: !controller.isCaught,
            onDecrement: onDecrement,
            onIncrement: onIncrement,
            onEdit: onEdit,
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicWidth(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onEdit,
                    child: CountInfoCard(
                      colors: colors,
                      startedAt: controller.startedAt,
                      caughtAt: controller.caughtAt,
                      caughtGame: controller.caughtGame,
                      formatter: formatDate,
                      onSelectGame: onEdit,
                      onGameChanged: onGameChanged,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDailyCounts,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: DailyCountsList(
                      colors: colors,
                      dailyCounts: controller.dailyCounts,
                      dayFormatter: formatDayKey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
