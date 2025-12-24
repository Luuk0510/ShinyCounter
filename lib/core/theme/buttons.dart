import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/colors.dart';

class AppButtonPalette {
  static Color primaryFill(ColorScheme colors) {
    return colors.primary;
  }

  static Color primaryOnFill(ColorScheme colors) {
    return colors.onPrimary;
  }

  static Color primaryAccent(ColorScheme colors) {
    return _brighten(colors.primary);
  }

  static Color primaryHighlight(ColorScheme colors) {
    return Color.lerp(colors.primary, Colors.white, 0.25)!;
  }

  static Color outline(ColorScheme colors) {
    return colors.primary;
  }

  static Color outlineBackground(ColorScheme colors) {
    return colors.primary.withValues(alpha: 0.08);
  }

  static Color text(ColorScheme colors) => colors.primary;

  static Color outlineMuted(ColorScheme colors) {
    return colors.primary;
  }

  static Color outlineBackgroundMuted(ColorScheme colors) {
    return colors.primary.withValues(alpha: 0.08);
  }

  static Color textMuted(ColorScheme colors) {
    return colors.primary;
  }

  static Color outlineMutedLight(ColorScheme colors) {
    return primaryHighlight(colors);
  }

  static Color outlineBackgroundMutedLight(ColorScheme colors) {
    return primaryHighlight(colors).withValues(alpha: 0.12);
  }

  static Color textMutedLight(ColorScheme colors) {
    return primaryHighlight(colors);
  }

  static Color deleteIcon(ColorScheme colors) {
    return AppColors.deleteIcon;
  }

  static Color _brighten(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 1.20).clamp(0.0, 1.0)).toColor();
  }

  static Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 0.85).clamp(0.0, 1.0)).toColor();
  }
}

class AppButtonStyles {
  static ButtonStyle primaryFilled(ColorScheme colors, {EdgeInsets? padding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppButtonPalette.primaryFill(colors),
      foregroundColor: AppButtonPalette.primaryOnFill(colors),
      disabledBackgroundColor: colors.onSurfaceVariant.withValues(alpha: 0.2),
      disabledForegroundColor: colors.onSurfaceVariant.withValues(alpha: 0.6),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      padding: padding,
    );
  }

  static ButtonStyle primaryOutline(
    ColorScheme colors, {
    EdgeInsets? padding,
    double borderWidth = 1.4,
    Color? backgroundColor,
    bool useLighter = false,
  }) {
    final foreground = useLighter
        ? AppButtonPalette.textMutedLight(colors)
        : AppButtonPalette.textMuted(colors);
    final outline = useLighter
        ? AppButtonPalette.outlineMutedLight(colors)
        : AppButtonPalette.outlineMuted(colors);
    final background = useLighter
        ? AppButtonPalette.outlineBackgroundMutedLight(colors)
        : AppButtonPalette.outlineBackgroundMuted(colors);
    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      side: BorderSide(color: outline, width: borderWidth),
      backgroundColor: backgroundColor ?? background,
      padding: padding,
    );
  }

  static ButtonStyle primaryText(ColorScheme colors, {EdgeInsets? padding}) {
    return TextButton.styleFrom(
      foregroundColor: AppButtonPalette.text(colors),
      padding: padding,
    );
  }

  static ButtonStyle destructiveFilled(
    ColorScheme colors, {
    EdgeInsets? padding,
  }) {
    final deleteColor = AppButtonPalette.deleteIcon(colors);
    final onDelete =
        ThemeData.estimateBrightnessForColor(deleteColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return ElevatedButton.styleFrom(
      backgroundColor: deleteColor,
      foregroundColor: onDelete,
      disabledBackgroundColor: deleteColor.withValues(alpha: 0.4),
      disabledForegroundColor: colors.onSurfaceVariant.withValues(alpha: 0.6),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      padding: padding,
    );
  }
}
