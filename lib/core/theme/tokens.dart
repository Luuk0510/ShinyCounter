import 'package:flutter/material.dart';

class AppColors {
  static const seed = Color(0xFF3F51B5);
  static const darkBackground = Color(0xFF151924);
  static const darkSurface = Color(0xFF1E2430);
  static const oledBackground = Color(0xFF000000);
  static const oledSurface = Color(0xFF0A0A0A);
}

class AppSpacing {
  static const none = 0.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppRadii {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 30.0;
}

// Dimensional tokens used across the app.
class AppSizes {
  // pokemon_list_page.dart
  static const toolbarHeight = 52.0;
  static const appBarActionIcon = 28.0;
  static const appBarTitleIcon = 36.0; // animated_app_icon.dart

  // settings_sheet.dart
  static const sheetHandleWidth = 44.0;
  static const sheetHandleHeight = 5.0;

  // add_pokemon_dialog.dart
  static const dialogMaxWidth = 420.0; // edit_pokemon_dialog.dart
  static const dialogHeightFactor = 0.75;
  static const dialogMinHeight = 240.0; // edit_pokemon_dialog.dart

  // add_pokemon_dialog.dart
  static const listMinHeight = 160.0; // manage_list_view.dart
  static const spriteThumb = 96.0; // pokemon_card.dart
  static const listItemMinHeight = 104.0;
  static const listScrollbarThickness = 7.0; // pokemon_list_page.dart

  // search_gen_filter_row.dart
  static const dropdownWidth = 115.0;

  // counter_controls.dart
  static const counterButtonSize = 72.0; // pokemon_detail_page.dart
  static const counterButtonPadding = 18.0;
  static const counterIconSize = 32.0;

  // edit_daily_counts_sheet.dart
  static const dailyListHeight = 210.0; // daily_counts_list.dart

  // pokemon_list_page
  static const dividerThickness = 1.0;

  // count_info_card.dart date_row.dart
  static const dateLabelSize = 17.0;
  static const dateValueSize = 18.0;

  // pokemon_detail_page.dart
  static const detailImageSize = 300.0;
  static const detailImageFallback = 140.0;

  // game_dropdown.dart
  static const gameLogoSize = 32.0; // count_info_card.dart
  static const gameLogoLarge = 40.0;
  static const gameLogoInnerScale = 1;
  static const gameSelectWidth = 240.0; // edit_counters_sheet.dart

  // pokemon_card.dart
  static const pokemonImageLarge = 150.0;
  static const pokemonImageSmall = 110.0;
  static const pokemonNameLarge = 37.0;
  static const pokemonNameSmall = 24.0;
  static const pokemonGapLarge = 16.0;
  static const pokemonGapSmall = 12.0;
  static const pokemonContentLarge = 14.0;
  static const pokemonContentSmall = 12.0;
  static const pokemonChevronLarge = AppSizes.appBarActionIcon;
  static const pokemonChevronSmall = 24.0;
  static const cardPaddingH = 10.0; // count_info_card.dart
  static const cardPaddingV = 4.0; // count_info_card.dart
  static const cardBorderRadius = 30.0; // count_info_card.dart
  static const cardElevation = 2.0; // count_info_card.dart
  static const cardActionBlur = 5.0;
  static const cardActionIcon = 28.0;
  static const cardActionIconScale = 1.3;

  // pokemon_empty_state.dart
  static const emptyStateImage = 96.0;
  static const emptyStateFallback = 72.0;
  static const emptyStateTitle = 18.0;
  static const emptyStateAction = 16.0;
  static const emptyStateButtonRadius = 14.0;
  static const emptyStateButtonWidth = 180.0;
  static const emptyStateButtonPadding = 14.0;

  // settings_sheet.dart
  static const settingsActionPaddingH = AppSpacing.xl;
  static const settingsActionPaddingV = AppSpacing.sm;
  static const sheetTitleTop = AppSpacing.lg;

  // counter_overlay.dart
  static const overlayControlPad = 14.0;
  static const overlayControlSize = 30.0;
  static const overlayControlGap = 1.0;
  static const overlayBlur = 14.0;
  static const overlayCorner = 150.0;
  static const overlayPadH = 12.0;
  static const overlayPadV = 10.0;
  static const overlayNameSize = 14.0;
  static const overlayCountSize = 26.0;
  static const overlayCloseSize = 24.0;
  static const overlayIconButtonSize = 36.0;
  static const overlaySpacer = 10.0;
  static const overlayTablePadH = 12.0;
  static const overlayTablePadV = 8.0;
  static const overlayTableCorner = 12.0;
  static const overlayLabelSize = 12.0;
  static const overlayValueSize = 14.0;
  static const overlayCellGap = 16.0;
  static const overlayLabelSpace = 2.0;

  // edit_counters_sheet.dart edit_daily_counts_sheet.dart
  static const sheetFieldLabel = 20.0;
  static const sheetFieldHint = 17.0;
  static const sheetFieldText = 18.0;
  static const sheetActionWidth = 1.4;
  static const sheetButtonFont = 16.0;
  static const sheetDateWidth = 110.0;
  static const sheetListHeightFactor = 0.72;

  /// pokemon_detail_page.dart
  static const pageIndicatorDot = 8.0;
  static const primaryButtonWidth = 150.0;
  static const buttonTextSize = 18.0;
}

class AppLimits {
  static const listSpritePrecacheCount = 8;
}

class AppOpacity {
  static const modalBarrier = 0.35;
  static const detailSheetBarrier = 0.4;
  static const cardActionScrim = 0.1;
  static const cardActionButton = 0.3;
}

class AppButtonPalette {
  static Color primaryFill(ColorScheme colors) {
    return AppColors.seed;
  }

  static Color primaryOnFill(ColorScheme colors) {
    return ThemeData.estimateBrightnessForColor(AppColors.seed) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color primaryAccent(ColorScheme colors) {
    return _brighten(primaryFill(colors));
  }

  static Color primaryHighlight(ColorScheme colors) {
    return Color.lerp(primaryFill(colors), Colors.white, 0.25)!;
  }

  static Color outline(ColorScheme colors) {
    return AppColors.seed;
  }

  static Color outlineBackground(ColorScheme colors) {
    return AppColors.seed.withValues(alpha: 0.08);
  }

  static Color text(ColorScheme colors) => AppColors.seed;

  static Color outlineMuted(ColorScheme colors) {
    return AppColors.seed;
  }

  static Color outlineBackgroundMuted(ColorScheme colors) {
    return AppColors.seed.withValues(alpha: 0.08);
  }

  static Color textMuted(ColorScheme colors) {
    return AppColors.seed;
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
      side: BorderSide(
        color: outline,
        width: borderWidth,
      ),
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
    return ElevatedButton.styleFrom(
      backgroundColor: colors.error,
      foregroundColor: colors.onError,
      disabledBackgroundColor: colors.error.withValues(alpha: 0.4),
      disabledForegroundColor: colors.onSurfaceVariant.withValues(alpha: 0.6),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      padding: padding,
    );
  }
}

class AppAnim {
  static const faster = Duration(milliseconds: 90);
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const switcher = Duration(milliseconds: 220);
  static const dialogDuration = fast;
  static const sheetDuration = Duration(milliseconds: 200);
  static const longPressDelay = Duration(milliseconds: 500);

  static const easeOut = Curves.easeOut;
  static const easeOutCubic = Curves.easeOutCubic;
  static const dialogCurve = easeOutCubic;
  static const sheetCurve = easeOutCubic;

  static const buttonPressScale = 0.9;
  static const dialogStartScale = 0.8;
  static const listItemPopStartScale = 0.96;
}

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
  static const chip = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xs,
  );
}

/// Semantic heights/widths to describe intent, not pixels.
class AppSemanticSize {
  static const chipHeight = 32.0;
  static const dialogMaxWidth = AppSizes.dialogMaxWidth;
  static const dialogMinHeight = AppSizes.dialogMinHeight;
}

class AppTypography {
  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const listTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
}
