import 'dart:async';
import 'dart:convert';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:shiny_counter/core/storage/key_value_store.dart';
import '../../overlay/counter_overlay_message.dart';
import '../../domain/services/counter_sync.dart';
import '../../shared/utils/counter_keys.dart';

class CounterState {
  const CounterState({
    required this.count,
    required this.isCaught,
    this.startedAt,
    this.caughtAt,
    this.caughtGame,
    this.dailyCounts = const {},
  });

  final int count;
  final bool isCaught;
  final DateTime? startedAt;
  final DateTime? caughtAt;
  final String? caughtGame;
  final Map<String, int> dailyCounts;
}

class CounterSyncService implements CounterSync {
  CounterSyncService._(this._store);

  final KeyValueStore _store;
  static CounterSyncService? _instance;
  static final Stream<dynamic> _overlayStream = FlutterOverlayWindow
      .overlayListener
      .asBroadcastStream();

  @override
  Stream<dynamic> get overlayStream => _overlayStream;

  static Future<CounterSyncService> instance({KeyValueStore? store}) async {
    if (_instance != null) return _instance!;
    _instance = CounterSyncService._(store ?? SharedPrefsStore());
    return _instance!;
  }

  @override
  Future<CounterState> loadState(String counterKey, String caughtKey) async {
    await _store.reload();
    final keys = CounterKeys.fromCounterKey(counterKey);
    return CounterState(
      count: await _store.getInt(counterKey) ?? 0,
      isCaught: await _store.getBool(caughtKey) ?? false,
      startedAt: _readDate(await _store.getString(keys.startedAt)),
      caughtAt: _readDate(await _store.getString(keys.caughtAt)),
      caughtGame: await _store.getString(keys.caughtGame),
      dailyCounts: _readDailyCounts(await _store.getString(keys.dailyCounts)),
    );
  }

  @override
  Future<void> saveState(
    String counterKey,
    String caughtKey,
    CounterState state,
  ) async {
    await _store.setInt(counterKey, state.count);
    await _store.setBool(caughtKey, state.isCaught);
    await setStartedAt(counterKey, state.startedAt);
    await setCaughtAt(counterKey, state.caughtAt);
    await setCaughtGame(counterKey, state.caughtGame);
    await setDailyCounts(counterKey, state.dailyCounts);
  }

  @override
  Future<void> setCounter(String counterKey, int count) async {
    await _store.setInt(counterKey, count);
  }

  @override
  Future<void> setCaught(String caughtKey, bool isCaught) async {
    await _store.setBool(caughtKey, isCaught);
  }

  @override
  Future<void> setStartedAt(String counterKey, DateTime? startedAt) async {
    final key = CounterKeys.fromCounterKey(counterKey).startedAt;
    if (startedAt == null) {
      await _store.remove(key);
      return;
    }
    await _store.setString(key, startedAt.toIso8601String());
  }

  @override
  Future<void> setCaughtAt(String counterKey, DateTime? caughtAt) async {
    final key = CounterKeys.fromCounterKey(counterKey).caughtAt;
    if (caughtAt == null) {
      await _store.remove(key);
      return;
    }
    await _store.setString(key, caughtAt.toIso8601String());
  }

  @override
  Future<void> setCaughtGame(String counterKey, String? game) async {
    final key = CounterKeys.fromCounterKey(counterKey).caughtGame;
    if (game == null || game.isEmpty) {
      await _store.remove(key);
      return;
    }
    await _store.setString(key, game);
  }

  @override
  Future<void> clearHuntDates(String counterKey) async {
    final keys = CounterKeys.fromCounterKey(counterKey);
    await _store.remove(keys.startedAt);
    await _store.remove(keys.caughtAt);
    await _store.remove(keys.caughtGame);
  }

  @override
  Future<void> setDailyCounts(
    String counterKey,
    Map<String, int> counts,
  ) async {
    final key = CounterKeys.fromCounterKey(counterKey).dailyCounts;
    if (counts.isEmpty) {
      await _store.remove(key);
      return;
    }
    await _store.setString(key, jsonEncode(counts));
  }

  @override
  Future<void> showOverlay(
    CounterOverlayMessage message, {
    int width = 360,
    int height = 220,
  }) async {
    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: message.name,
      overlayContent: message.serialize(),
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
      height: height,
      width: width,
    );
    await shareToOverlay(message);
  }

  @override
  Future<void> shareToOverlay(CounterOverlayMessage message) async {
    await FlutterOverlayWindow.shareData(message.serialize());
  }

  @override
  Future<void> closeOverlay() => FlutterOverlayWindow.closeOverlay();

  DateTime? _readDate(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);

  Map<String, int> _readDailyCounts(String? raw) {
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map<String, int>((key, value) {
        final k = key.toString();
        final v = value is int ? value : int.tryParse(value.toString()) ?? 0;
        return MapEntry(k, v);
      })..removeWhere((_, v) => v == 0);
    } catch (_) {
      return {};
    }
  }
}
