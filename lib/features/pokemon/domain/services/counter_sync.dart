import 'dart:async';

import '../../overlay/counter_overlay_message.dart';
import '../../data/datasources/counter_sync_service.dart';

/// Abstraction for persisting counter state and syncing overlay data.
abstract class CounterSync {
  Future<CounterState> loadState(String counterKey, String caughtKey);
  Future<void> saveState(
    String counterKey,
    String caughtKey,
    CounterState state,
  );
  Future<void> setCounter(String counterKey, int count);
  Future<void> setCaught(String caughtKey, bool isCaught);
  Future<void> setStartedAt(String counterKey, DateTime? startedAt);
  Future<void> setCaughtAt(String counterKey, DateTime? caughtAt);
  Future<void> setCaughtGame(String counterKey, String? game);
  Future<void> clearHuntDates(String counterKey);
  Future<void> setDailyCounts(String counterKey, Map<String, int> counts);
  Future<void> showOverlay(
    CounterOverlayMessage message, {
    int width = 360,
    int height = 220,
  });
  Future<void> shareToOverlay(CounterOverlayMessage message);
  Future<void> closeOverlay();
  Stream<dynamic> get overlayStream;
}
