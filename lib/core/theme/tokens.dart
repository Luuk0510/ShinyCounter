import 'package:flutter/material.dart';

class AppColors {
  static const seed = Color(0xFF3F51B5);
  static const darkBackground = Color(0xFF151924);
  static const darkSurface = Color(0xFF1E2430);
  static const darkSurfaceVariant = Color(0xFF252C3A);
  static const oledBackground = Color(0xFF000000);
  static const oledSurface = Color(0xFF0A0A0A);
  static const oledSurfaceVariant = Color(0xFF121212);
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
    final cardColor = scheme.surface;
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
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
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurfaceVariant,
    );
    final cardColor = scheme.surfaceVariant.withOpacity(0.92);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
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
      background: AppColors.oledBackground,
      surface: AppColors.oledSurface,
      surfaceVariant: AppColors.oledSurfaceVariant,
    );
    const cardColor = Color(0xFF111111);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: Colors.white.withOpacity(0.04)),
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
