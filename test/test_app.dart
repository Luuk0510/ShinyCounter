import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';
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

class FakeCounterSync implements CounterSync {
  FakeCounterSync();

  final Map<String, CounterState> _store = {};
  final _stream = StreamController<dynamic>.broadcast();

  @override
  Stream<dynamic> get overlayStream => _stream.stream;

  @override
  Future<void> clearHuntDates(String counterKey) async {
    final state = _store[counterKey];
    if (state == null) return;
    _store[counterKey] = CounterState(
      count: state.count,
      isCaught: false,
      dailyCounts: state.dailyCounts,
    );
  }

  @override
  Future<void> closeOverlay() async {}

  @override
  Future<void> saveState(
    String counterKey,
    String caughtKey,
    CounterState state,
  ) async {
    _store[counterKey] = state;
  }

  @override
  Future<void> setCaught(String caughtKey, bool isCaught) async {
    // This fake ignores caughtKey and stores by counterKey.
  }

  @override
  Future<void> setCaughtAt(String counterKey, DateTime? caughtAt) async {
    final state = _store[counterKey];
    if (state == null) return;
    _store[counterKey] = CounterState(
      count: state.count,
      isCaught: state.isCaught,
      startedAt: state.startedAt,
      caughtAt: caughtAt,
      caughtGame: state.caughtGame,
      dailyCounts: state.dailyCounts,
    );
  }

  @override
  Future<void> setCaughtGame(String counterKey, String? game) async {
    final state = _store[counterKey];
    if (state == null) return;
    _store[counterKey] = CounterState(
      count: state.count,
      isCaught: state.isCaught,
      startedAt: state.startedAt,
      caughtAt: state.caughtAt,
      caughtGame: game,
      dailyCounts: state.dailyCounts,
    );
  }

  @override
  Future<void> setCounter(String counterKey, int count) async {
    final prev = _store[counterKey];
    _store[counterKey] = CounterState(
      count: count,
      isCaught: prev?.isCaught ?? false,
      startedAt: prev?.startedAt,
      caughtAt: prev?.caughtAt,
      caughtGame: prev?.caughtGame,
      dailyCounts: prev?.dailyCounts ?? const {},
    );
  }

  @override
  Future<void> setDailyCounts(
    String counterKey,
    Map<String, int> counts,
  ) async {
    final prev = _store[counterKey];
    _store[counterKey] = CounterState(
      count: prev?.count ?? 0,
      isCaught: prev?.isCaught ?? false,
      startedAt: prev?.startedAt,
      caughtAt: prev?.caughtAt,
      caughtGame: prev?.caughtGame,
      dailyCounts: counts,
    );
  }

  @override
  Future<void> setStartedAt(String counterKey, DateTime? startedAt) async {
    final prev = _store[counterKey];
    _store[counterKey] = CounterState(
      count: prev?.count ?? 0,
      isCaught: prev?.isCaught ?? false,
      startedAt: startedAt,
      caughtAt: prev?.caughtAt,
      caughtGame: prev?.caughtGame,
      dailyCounts: prev?.dailyCounts ?? const {},
    );
  }

  @override
  Future<void> shareToOverlay(CounterOverlayMessage message) async {
    _stream.add(message.serialize());
  }

  @override
  Future<void> showOverlay(
    CounterOverlayMessage message, {
    int width = 360,
    int height = 220,
  }) async {
    _stream.add(message.serialize());
  }

  @override
  Future<CounterState> loadState(String counterKey, String caughtKey) async {
    return _store[counterKey] ??
        const CounterState(count: 0, isCaught: false, dailyCounts: {});
  }
}

/// Common test harness that wires providers/localizations for widgets.
Widget buildTestApp(
  Widget child, {
  SpriteService? spriteService,
  CounterSync? counterSync,
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
      Provider<CounterSync>.value(
        value: counterSync ?? FakeCounterSync(),
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
