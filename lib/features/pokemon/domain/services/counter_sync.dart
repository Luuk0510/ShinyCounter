import 'dart:async';

import '../entities/counter_state.dart';
import '../entities/counter_overlay_payload.dart';

/// Abstraction for persisting counter state and syncing overlay data.
abstract class CounterSync {
  Future<CounterState> loadState(String counterKey, String caughtKey);
  Future<List<CounterState>> loadStates(Iterable<String> counterKeys);
  Future<void> saveState(
    String counterKey,
    String caughtKey,
    CounterState state,
  );
  Future<void> clearPokemonState(String pokemonId);
  Future<void> setCounter(String counterKey, int count);
  Future<void> setCaught(String caughtKey, bool isCaught);
  Future<void> setStartedAt(String counterKey, DateTime? startedAt);
  Future<void> setCaughtAt(String counterKey, DateTime? caughtAt);
  Future<void> setCaughtGame(String counterKey, String? game);
  Future<void> clearHuntDates(String counterKey);
  Future<void> setDailyCounts(String counterKey, Map<String, int> counts);
  Future<bool> ensureOverlay(
    CounterOverlayPayload payload, {
    int width = 360,
    int height = 220,
  });
  Future<void> showOverlay(
    CounterOverlayPayload payload, {
    int width = 360,
    int height = 220,
  });
  Future<bool> isOverlayActive();
  Future<void> shareToOverlay(CounterOverlayPayload payload);
  Future<void> closeOverlay();
  Stream<dynamic> get overlayStream;
}
