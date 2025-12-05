import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

/// Lightweight fake sprite service for widget tests.
class FakeSpriteService implements SpriteService {
  FakeSpriteService({this.sprites = const []});

  final List<ParsedSprite> sprites;

  @override
  Future<List<ParsedSprite>> loadSprites({bool refresh = false}) async =>
      sprites;
}

/// Common test harness that wires providers/localizations for widgets.
Widget buildTestApp(
  Widget child, {
  SpriteService? spriteService,
  Locale? locale,
  ThemeMode mode = ThemeMode.light,
}) {
  // Ensure SharedPreferences writes stay in memory during tests.
  SharedPreferences.setMockInitialValues({});

  final themeNotifier = ThemeNotifier()..setMode(mode);
  final localeNotifier = LocaleNotifier();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
      ChangeNotifierProvider<LocaleNotifier>.value(value: localeNotifier),
      Provider<SpriteService>.value(
        value: spriteService ?? FakeSpriteService(),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
