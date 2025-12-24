import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/spacing.dart';
import 'package:shiny_counter/core/theme/sizes.dart';

/// Intent-based tokens to avoid sprinkling raw numbers in widgets.
class AppInsets {
  static const card = EdgeInsets.symmetric(
    horizontal: AppSizes.cardPaddingH,
    vertical: AppSizes.cardPaddingV,
  );
  static const dialog = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  );
  static const sheet = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  );
  static const overlay = EdgeInsets.symmetric(
    horizontal: AppSizes.overlayPadH,
    vertical: AppSizes.overlayPadV,
  );
  static const page = EdgeInsets.fromLTRB(
    AppSpacing.sm,
    AppSpacing.lg,
    AppSpacing.sm,
    AppSpacing.xl,
  );
  static EdgeInsets pageWithBottomInset(double bottomInset) {
    return EdgeInsets.fromLTRB(
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.xl + bottomInset,
    );
  }

  static const chip = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xs,
  );
}
