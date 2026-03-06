import 'dart:async';
import 'dart:convert';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:shiny_counter/core/storage/key_value_store.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/counter_state.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/counter_overlay_payload.dart';
import '../../overlay/counter_overlay_message.dart';
import '../../domain/services/counter_sync.dart';
import '../../shared/utils/counter_keys.dart';

class CounterSyncService implements CounterSync {
  CounterSyncService({KeyValueStore? store})
    : _store = store ?? SharedPrefsStore();

  final KeyValueStore _store;
  static final Stream<dynamic> _overlayStream = FlutterOverlayWindow
      .overlayListener
      .asBroadcastStream();

  @override
  Stream<dynamic> get overlayStream => _overlayStream;

  @override
  Future<CounterState> loadState(String counterKey, String caughtKey) async {
    final values = await _store.snapshot(reload: true);
    return _readState(counterKey, caughtKey, values);
  }

  @override
  Future<List<CounterState>> loadStates(Iterable<String> counterKeys) async {
    final values = await _store.snapshot(reload: true);
    return [
      for (final counterKey in counterKeys)
        _readState(
          counterKey,
          CounterKeys.fromCounterKey(counterKey).caught,
          values,
        ),
    ];
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
  Future<void> clearPokemonState(String pokemonId) async {
    final keys = CounterKeys.fromId(pokemonId);
    await _store.remove(keys.counter);
    await _store.remove(keys.caught);
    await clearHuntDates(keys.counter);
    await setDailyCounts(keys.counter, {});
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
  Future<bool> ensureOverlay(
    CounterOverlayPayload payload, {
    int width = 360,
    int height = 220,
  }) async {
    final hasPerm = await FlutterOverlayWindow.isPermissionGranted();
    if (!hasPerm) {
      final requested = await FlutterOverlayWindow.requestPermission();
      if (requested != true) return false;
    }
    final active = await FlutterOverlayWindow.isActive();
    if (active) {
      await shareToOverlay(payload);
      return true;
    }
    await showOverlay(payload, width: width, height: height);
    return true;
  }

  @override
  Future<void> showOverlay(
    CounterOverlayPayload payload, {
    int width = 360,
    int height = 220,
  }) async {
    final message = _toOverlayMessage(payload);
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
    await shareToOverlay(payload);
  }

  @override
  Future<bool> isOverlayActive() => FlutterOverlayWindow.isActive();

  @override
  Future<void> shareToOverlay(CounterOverlayPayload payload) async {
    final message = _toOverlayMessage(payload);
    await FlutterOverlayWindow.shareData(message.serialize());
  }

  @override
  Future<void> closeOverlay() => FlutterOverlayWindow.closeOverlay();

  DateTime? _readDate(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);

  CounterState _readState(
    String counterKey,
    String caughtKey,
    Map<String, Object?> values,
  ) {
    final keys = CounterKeys.fromCounterKey(counterKey);
    return CounterState(
      count: values[counterKey] as int? ?? 0,
      isCaught: values[caughtKey] as bool? ?? false,
      startedAt: _readDate(values[keys.startedAt] as String?),
      caughtAt: _readDate(values[keys.caughtAt] as String?),
      caughtGame: values[keys.caughtGame] as String?,
      dailyCounts: _readDailyCounts(values[keys.dailyCounts] as String?),
    );
  }

  CounterOverlayMessage _toOverlayMessage(CounterOverlayPayload payload) {
    return CounterOverlayMessage(
      name: payload.name,
      counterKey: payload.counterKey,
      count: payload.count,
      enabled: payload.enabled,
    );
  }

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
