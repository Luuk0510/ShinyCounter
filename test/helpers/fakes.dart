import 'dart:async';

import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

class FakeCounterSync implements CounterSync {
  final Map<String, int> counters = {};
  final Map<String, bool> caught = {};
  final Map<String, DateTime?> started = {};
  final Map<String, DateTime?> caughtAt = {};
  final Map<String, String?> caughtGame = {};
  final Map<String, Map<String, int>> daily = {};
  final _overlayController = StreamController<dynamic>.broadcast();

  @override
  Stream<dynamic> get overlayStream => _overlayController.stream;

  @override
  Future<void> clearHuntDates(String counterKey) async {
    started[counterKey] = null;
    caughtAt[counterKey] = null;
  }

  @override
  Future<void> closeOverlay() async {}

  @override
  Future<CounterState> loadState(String counterKey, String caughtKey) async {
    return CounterState(
      count: counters[counterKey] ?? 0,
      isCaught: caught[caughtKey] ?? false,
      startedAt: started[counterKey],
      caughtAt: caughtAt[counterKey],
      caughtGame: caughtGame[counterKey],
      dailyCounts: daily[counterKey] ?? const {},
    );
  }

  @override
  Future<void> saveState(
    String counterKey,
    String caughtKey,
    CounterState state,
  ) async {
    counters[counterKey] = state.count;
    caught[caughtKey] = state.isCaught;
    started[counterKey] = state.startedAt;
    caughtAt[counterKey] = state.caughtAt;
    caughtGame[counterKey] = state.caughtGame;
    daily[counterKey] = Map.of(state.dailyCounts);
  }

  @override
  Future<void> setCaught(String caughtKey, bool isCaught) async {
    caught[caughtKey] = isCaught;
  }

  @override
  Future<void> setCaughtAt(String counterKey, DateTime? value) async {
    caughtAt[counterKey] = value;
  }

  @override
  Future<void> setCaughtGame(String counterKey, String? game) async {
    caughtGame[counterKey] = game;
  }

  @override
  Future<void> setCounter(String counterKey, int count) async {
    counters[counterKey] = count;
  }

  @override
  Future<void> setDailyCounts(String counterKey, Map<String, int> counts) async {
    daily[counterKey] = counts;
  }

  @override
  Future<void> setStartedAt(String counterKey, DateTime? startedAt) async {
    started[counterKey] = startedAt;
  }

  @override
  Future<void> shareToOverlay(CounterOverlayMessage message) async {}

  @override
  Future<void> showOverlay(
    CounterOverlayMessage message, {
    int width = 360,
    int height = 220,
  }) async {}
}

class FakeSpriteService implements SpriteService {
  FakeSpriteService(this._sprites);

  final List<ParsedSprite> _sprites;

  @override
  Future<List<ParsedSprite>> loadSprites({bool refresh = false}) async =>
      _sprites;

  @override
  Future<List<ParsedSprite>> spritesForDex(String dex,
      {bool refresh = false}) async {
    return _sprites.where((s) => s.dex == dex).toList();
  }

  @override
  Future<void> warmupForDexes(Iterable<String> dexes,
      {bool refresh = false}) async {}
}
