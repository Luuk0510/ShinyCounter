import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.bottomSpacing = AppSpacing.lg,
  });

  final String title;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.sheetHandleWidth,
          height: AppSizes.sheetHandleHeight,
          decoration: BoxDecoration(
            color: colors.outlineVariant,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}
