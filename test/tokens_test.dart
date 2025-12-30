import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

void main() {
  test('tokens expose expected base values', () {
    expect(AppSpacing.sm, 8.0);
    expect(AppRadii.md, 16.0);
    expect(AppSizes.toolbarHeight, 52.0);
    expect(AppAnim.normal, const Duration(milliseconds: 200));
  });

  test('insets map back to size tokens', () {
    expect(AppInsets.card.horizontal, AppSizes.cardPaddingH * 2);
    expect(AppInsets.card.vertical, AppSizes.cardPaddingV * 2);
    expect(AppInsets.overlay.horizontal, AppSizes.overlayPadH * 2);
    expect(AppInsets.overlay.vertical, AppSizes.overlayPadV * 2);
  });

  test('typography tokens are defined', () {
    expect(AppTypography.title.fontSize, 26);
    expect(AppTypography.button.fontWeight, FontWeight.w700);
  });
}
