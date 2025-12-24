import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

void main() {
  test('primary palette uses seed color', () {
    final colors = ColorScheme.fromSeed(seedColor: AppColors.seed);
    expect(AppButtonPalette.primaryFill(colors), colors.primary);
    expect(AppButtonPalette.primaryOnFill(colors), colors.onPrimary);
    expect(
      AppButtonPalette.primaryHighlight(colors),
      Color.lerp(colors.primary, Colors.white, 0.25),
    );
  });

  test('primary filled button style resolves colors', () {
    final colors = ColorScheme.fromSeed(seedColor: AppColors.seed);
    final style = AppButtonStyles.primaryFilled(colors);
    expect(
      style.backgroundColor?.resolve(<WidgetState>{}),
      AppButtonPalette.primaryFill(colors),
    );
    expect(
      style.foregroundColor?.resolve(<WidgetState>{}),
      AppButtonPalette.primaryOnFill(colors),
    );
  });

  test('destructive style resolves error colors', () {
    final colors = const ColorScheme.light();
    final style = AppButtonStyles.destructiveFilled(colors);
    final deleteColor = AppButtonPalette.deleteIcon(colors);
    final onDelete =
        ThemeData.estimateBrightnessForColor(deleteColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
    expect(style.backgroundColor?.resolve(<WidgetState>{}), deleteColor);
    expect(style.foregroundColor?.resolve(<WidgetState>{}), onDelete);
  });
}
