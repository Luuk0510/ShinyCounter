import 'dart:async';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_overlay_window/src/models/overlay_position.dart';
import 'package:flutter_overlay_window/src/overlay_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../overlay/counter_overlay_message.dart';

class CounterState {
  const CounterState({required this.count, required this.isCaught});

  final int count;
  final bool isCaught;
}

class CounterSyncService {
  CounterSyncService._(this._prefs);

  final SharedPreferences _prefs;
  static CounterSyncService? _instance;
  static final Stream<dynamic> overlayStream =
      FlutterOverlayWindow.overlayListener.asBroadcastStream();

  static Future<CounterSyncService> instance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = CounterSyncService._(prefs);
    return _instance!;
  }

  Future<CounterState> loadState(String counterKey, String caughtKey) async {
    await _prefs.reload();
    return CounterState(
      count: _prefs.getInt(counterKey) ?? 0,
      isCaught: _prefs.getBool(caughtKey) ?? false,
    );
  }

  Future<void> saveState(String counterKey, String caughtKey, CounterState state) async {
    await _prefs.setInt(counterKey, state.count);
    await _prefs.setBool(caughtKey, state.isCaught);
  }

  Future<void> setCounter(String counterKey, int count) async {
    await _prefs.setInt(counterKey, count);
  }

  Future<void> setCaught(String caughtKey, bool isCaught) async {
    await _prefs.setBool(caughtKey, isCaught);
  }

  Future<void> showOverlay(
    CounterOverlayMessage message, {
    int width = 360,
    int height = 220,
    OverlayPosition? start,
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
      startPosition: start,
    );
    await shareToOverlay(message);
  }

  Future<void> shareToOverlay(CounterOverlayMessage message) async {
    await FlutterOverlayWindow.shareData(message.serialize());
  }

  Future<void> closeOverlay() => FlutterOverlayWindow.closeOverlay();
}
