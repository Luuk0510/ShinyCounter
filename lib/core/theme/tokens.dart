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

class AppSizes {
  static const toolbarHeight = 52.0;
  static const sheetHandleWidth = 44.0;
  static const sheetHandleHeight = 5.0;
  static const dialogMaxWidth = 420.0;
  static const dialogHeightFactor = 0.75;
  static const dialogMinHeight = 240.0;
  static const listMinHeight = 160.0;
  static const spriteThumb = 96.0;
  static const listItemMinHeight = 104.0;
  static const dropdownWidth = 105.0;
  static const counterButtonSize = 72.0;
  static const counterButtonPadding = 18.0;
  static const counterIconSize = 32.0;
  static const dailyListHeight = 210.0;
  static const dividerThickness = 1.0;
  static const dateLabelSize = 17.0;
  static const dateValueSize = 18.0;
  static const detailImageSize = 300.0;
  static const detailImageFallback = 140.0;
  static const gameLogoSize = 32.0;
  static const gameLogoLarge = 40.0;
  static const gameSelectWidth = 240.0;
  static const cardPaddingH = 16.0;
  static const cardPaddingV = 8.0;
  static const cardBorderRadius = 30.0;
  static const cardElevation = 2.0;
  static const pokemonImageLarge = 150.0;
  static const pokemonImageSmall = 110.0;
  static const pokemonNameLarge = 37.0;
  static const pokemonNameSmall = 24.0;
  static const pokemonGapLarge = 16.0;
  static const pokemonGapSmall = 12.0;
  static const pokemonContentLarge = 14.0;
  static const pokemonContentSmall = 12.0;
  static const pokemonChevronLarge = 28.0;
  static const pokemonChevronSmall = 24.0;
  static const emptyStateImage = 96.0;
  static const emptyStateFallback = 72.0;
  static const emptyStateTitle = 18.0;
  static const emptyStateAction = 16.0;
  static const emptyStateButtonRadius = 14.0;
  static const emptyStateButtonWidth = 180.0;
  static const emptyStateButtonPadding = 14.0;
  static const settingsActionPaddingH = AppSpacing.xl;
  static const settingsActionPaddingV = AppSpacing.sm;
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
  static const sheetTitleTop = AppSpacing.lg;
  static const sheetFieldLabel = 20.0;
  static const sheetFieldHint = 17.0;
  static const sheetFieldText = 18.0;
  static const sheetActionWidth = 1.4;
  static const sheetButtonFont = 16.0;
  static const sheetDateWidth = 110.0;
  static const sheetListHeightFactor = 0.72;
  static const pageIndicatorDot = 8.0;
  static const primaryButtonWidth = 150.0;
}

class AppAnim {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const switcher = Duration(milliseconds: 220);
  static const dialogDuration = fast;
  static const sheetDuration = Duration(milliseconds: 200);

  static const easeOut = Curves.easeOut;
  static const easeOutCubic = Curves.easeOutCubic;
  static const dialogCurve = easeOutCubic;
  static const sheetCurve = easeOutCubic;

  static const buttonPressScale = 0.9;
  static const dialogStartScale = 0.8;
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
