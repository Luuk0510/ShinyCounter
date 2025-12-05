import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';

class DailyCountsList extends StatelessWidget {
  const DailyCountsList({
    super.key,
    required this.colors,
    required this.dailyCounts,
    required this.dayFormatter,
  });

  final ColorScheme colors;
  final Map<String, int> dailyCounts;
  final String Function(String) dayFormatter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = dailyCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    if (entries.isEmpty) {
      return Container(
        height: 210,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          l10n.noCounts,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dateLabel,
                  style: AppTypography.button.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.countLabel,
                  style: AppTypography.button.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayFormatter(entry.key),
                      style: AppTypography.sectionTitle.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: AppTypography.sectionTitle.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, _) => Divider(
                height: AppSpacing.lg,
                thickness: 1,
                color: colors.outlineVariant.withValues(alpha: 0.25),
              ),
              itemCount: entries.length,
            ),
          ),
        ],
      ),
    );
  }
}
