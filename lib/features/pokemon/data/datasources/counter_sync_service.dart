import 'dart:async';
import 'dart:convert';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../overlay/counter_overlay_message.dart';
import '../../domain/services/counter_sync.dart';

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
  CounterSyncService._(this._prefs);

  final SharedPreferences _prefs;
  static CounterSyncService? _instance;
  static final Stream<dynamic> _overlayStream = FlutterOverlayWindow
      .overlayListener
      .asBroadcastStream();

  @override
  Stream<dynamic> get overlayStream => _overlayStream;

  static Future<CounterSyncService> instance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = CounterSyncService._(prefs);
    return _instance!;
  }

  @override
  Future<CounterState> loadState(String counterKey, String caughtKey) async {
    await _prefs.reload();
    return CounterState(
      count: _prefs.getInt(counterKey) ?? 0,
      isCaught: _prefs.getBool(caughtKey) ?? false,
      startedAt: _readDate(_prefs.getString(_startedAtKey(counterKey))),
      caughtAt: _readDate(_prefs.getString(_caughtAtKey(counterKey))),
      caughtGame: _prefs.getString(_caughtGameKey(counterKey)),
      dailyCounts: _readDailyCounts(
        _prefs.getString(_dailyCountsKey(counterKey)),
      ),
    );
  }

  Future<void> saveState(
    String counterKey,
    String caughtKey,
    CounterState state,
  ) async {
    await _prefs.setInt(counterKey, state.count);
    await _prefs.setBool(caughtKey, state.isCaught);
    await setStartedAt(counterKey, state.startedAt);
    await setCaughtAt(counterKey, state.caughtAt);
    await setCaughtGame(counterKey, state.caughtGame);
    await setDailyCounts(counterKey, state.dailyCounts);
  }

  Future<void> setCounter(String counterKey, int count) async {
    await _prefs.setInt(counterKey, count);
  }

  @override
  Future<void> setCaught(String caughtKey, bool isCaught) async {
    await _prefs.setBool(caughtKey, isCaught);
  }

  @override
  Future<void> setStartedAt(String counterKey, DateTime? startedAt) async {
    final key = _startedAtKey(counterKey);
    if (startedAt == null) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, startedAt.toIso8601String());
  }

  Future<void> setCaughtAt(String counterKey, DateTime? caughtAt) async {
    final key = _caughtAtKey(counterKey);
    if (caughtAt == null) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, caughtAt.toIso8601String());
  }

  Future<void> setCaughtGame(String counterKey, String? game) async {
    final key = _caughtGameKey(counterKey);
    if (game == null || game.isEmpty) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, game);
  }

  Future<void> clearHuntDates(String counterKey) async {
    await _prefs.remove(_startedAtKey(counterKey));
    await _prefs.remove(_caughtAtKey(counterKey));
    await _prefs.remove(_caughtGameKey(counterKey));
  }

  Future<void> setDailyCounts(
    String counterKey,
    Map<String, int> counts,
  ) async {
    final key = _dailyCountsKey(counterKey);
    if (counts.isEmpty) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, jsonEncode(counts));
  }

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

  String _startedAtKey(String counterKey) => '${counterKey}_startedAt';

  String _caughtAtKey(String counterKey) => '${counterKey}_caughtAt';

  String _caughtGameKey(String counterKey) => '${counterKey}_caughtGame';

  String _dailyCountsKey(String counterKey) => '${counterKey}_dailyCounts';

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
