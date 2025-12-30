import 'package:flutter/material.dart';

import 'tokens.dart';

class AppTheme {
  static final themes = <String, ThemeData>{
    'light': light(),
    'dark': dark(),
    'oled': oled(),
  };

  static ThemeData light({Color? seedColor}) {
    final scheme = ColorScheme.fromSeed(seedColor: seedColor ?? AppColors.seed);
    final cardColor = scheme.surfaceContainerHigh;
    return ThemeData(
      colorScheme: scheme.copyWith(
        surface: scheme.surface,
        surfaceContainerHighest: scheme.surfaceContainerHighest,
      ),
      scaffoldBackgroundColor: scheme.surface,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(),
      useMaterial3: true,
    );
  }

  static ThemeData dark({Color? seedColor}) {
    final seed = seedColor ?? AppColors.seed;
    final darkSchemeBase = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    final tintedSurface = Color.lerp(AppColors.darkSurface, seed, 0.08)!;
    final tintedBackground = Color.lerp(AppColors.darkBackground, seed, 0.06)!;
    final scheme = darkSchemeBase.copyWith(
      surface: tintedSurface,
      surfaceContainerHighest: tintedSurface,
    );
    final cardColor = scheme.surfaceContainerHighest;
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: tintedBackground,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      appBarTheme: const AppBarTheme(),
      useMaterial3: true,
    );
  }

  static ThemeData oled({Color? seedColor}) {
    final darkSchemeBase = ColorScheme.fromSeed(
      seedColor: seedColor ?? AppColors.seed,
      brightness: Brightness.dark,
    );
    final scheme = darkSchemeBase.copyWith(
      surface: AppColors.oledSurface,
      surfaceContainerHighest: const Color(0xFF0F0F0F),
    );
    final cardColor = scheme.surfaceContainerHighest;
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.oledBackground,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0A0A0A),
        surfaceTintColor: Colors.black,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      dividerColor: Colors.white10,
      useMaterial3: true,
    );
  }
}
