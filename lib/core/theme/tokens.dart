import 'package:flutter/material.dart';

class AppColors {
  static const seed = Color(0xFF3F51B5);
  static const darkBackground = Color(0xFF151924);
  static const darkSurface = Color(0xFF1E2430);
  static const oledBackground = Color(0xFF000000);
  static const oledSurface = Color(0xFF0A0A0A);
}

class AppSpacing {
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

class AppTypography {
  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
}

class AppTheme {
  static final themes = <String, ThemeData>{
    'light': light(),
    'dark': dark(),
    'oled': oled(),
  };

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.seed);
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

  static ThemeData dark() {
    final darkSchemeBase = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    );
    final scheme = darkSchemeBase.copyWith(
      surface: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkSurface,
    );
    final cardColor = scheme.surfaceContainerHighest;
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
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

  static ThemeData oled() {
    final darkSchemeBase = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
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
