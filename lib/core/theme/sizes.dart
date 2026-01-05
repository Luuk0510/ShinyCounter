import 'package:shiny_counter/core/theme/spacing.dart';

// Dimensional tokens used across the app.
class AppSizes {
  // pokemon_list_page.dart
  static const toolbarHeight = 52.0;
  static const appBarActionIcon = 28.0;
  static const appBarTitleIcon = 36.0; // animated_app_icon.dart

  // settings_sheet.dart
  static const sheetHandleWidth = 44.0;
  static const sheetHandleHeight = 5.0;
  static const seedSwatch = 20.0;

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
  static const counterButtonSize = 90.0; // pokemon_detail_page.dart
  static const counterButtonPadding = 18.0;
  static const counterIconSize = 32.0;

  // edit_daily_counts_sheet.dart
  static const dailyListHeight = 210.0; // daily_counts_list.dart

  // pokemon_list_page
  static const dividerThickness = 1.0;

  // pokemon_stats_page.dart
  static const statsPokemonImage = 44.0;
  static const statsGameCountWidth = 50.0;
  static const statsCaughtGameTableMaxWidth = 230.0;
  static const statsRecentCatchTableMaxWidth = 300.0;
  static const statsResetsPokemonTableMaxWidth = 260.0;
  static const statsDateWidth = 115.0;
  static const statsRowTextSize = 20.0;
  static const statsExpandableMaxVisible = 10;
  static const statsExpandableRowHeight =
      statsPokemonImage + (AppSpacing.xs * 2);
  static const statsChartHeight = 200.0;
  static const statsChartHeightCompact = 180.0;
  static const statsChartStroke = 2.0;
  static const statsPieRadiusFactor = 0.34;
  static const statsPieCenterSpaceFactor = 0.22;
  static const statsPieSectionGap = 1.5;
  static const statsPieLabelMinPercent = 7.0;
  static const statsPieLabelOffset = 0.6;
  static const statsPieLegendMinWidth = 560.0;
  static const statsRangeTextSize = 16.0;
  static const statsRangeStackWidth = 360.0;
  static const statsRangeStackGap = 0.0;
  static const statsChartTooltipWidth = 160.0;
  static const statsChartTooltipHeight = 54.0;

  // pokemon_game_stats_page.dart
  static const statsGameRowImage = 110.0;
  static const statsGameTableMaxWidth = 450.0;
  static const statsGameRowTextSize = 25.0;
  static const statsGameDateWidth = 200.0;

  // count_info_card.dart date_row.dart
  static const dateLabelSize = 17.0;
  static const dateValueSize = 18.0;

  // pokemon_detail_page.dart
  static const detailImageSize = 300.0;
  static const detailImageFallback = 140.0;
  static const catchSparkleSize = 64.0;

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
  static const cardActionButtonWidthScale = 3.0;
  static const cardActionButtonHeightScale = 2.5;

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
  static const pageIndicatorDotActive = 10.0;
  static const primaryButtonWidth = 150.0;
  static const buttonTextSize = 18.0;
}

class AppLimits {
  static const listSpritePrecacheCount = 8;
}

/// Semantic heights/widths to describe intent, not pixels.
class AppSemanticSize {
  static const chipHeight = 32.0;
  static const dialogMaxWidth = AppSizes.dialogMaxWidth;
  static const dialogMinHeight = AppSizes.dialogMinHeight;
}
