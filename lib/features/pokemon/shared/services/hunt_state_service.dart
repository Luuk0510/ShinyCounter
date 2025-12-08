import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

class HuntStateUpdate {
  const HuntStateUpdate({
    required this.startedAt,
    required this.caughtAt,
    required this.isCaught,
    required this.caughtGame,
    required this.dailyCounts,
  });

  final DateTime? startedAt;
  final DateTime? caughtAt;
  final bool isCaught;
  final String? caughtGame;
  final Map<String, int> dailyCounts;
}

/// Centralized logic for hunt start/end dates and daily count tracking.
class HuntStateService {
  HuntStateService({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  Future<HuntStateUpdate> applyCountChange({
    required CounterKeys keys,
    required CounterSync sync,
    required int previousCount,
    required int nextCount,
    required bool isCaught,
    required DateTime? startedAt,
    required DateTime? caughtAt,
    required String? caughtGame,
    required Map<String, int> dailyCounts,
    DateTime? day,
  }) async {
    final delta = nextCount - previousCount;
    var nextStartedAt = startedAt;
    var nextCaughtAt = caughtAt;
    var nextCaught = isCaught;
    var nextGame = caughtGame;
    final updatedCounts = Map<String, int>.from(dailyCounts);

    if (previousCount == 0 && nextCount > 0) {
      nextStartedAt = _clock();
      nextCaughtAt = null;
      await sync.setStartedAt(keys.counter, nextStartedAt);
      await sync.setCaughtAt(keys.counter, null);
    } else if (nextCount == 0) {
      nextStartedAt = null;
      nextCaughtAt = null;
      nextCaught = false;
      nextGame = null;
      await sync.clearHuntDates(keys.counter);
      await sync.setCaught(keys.caught, false);
    }

    if (delta != 0) {
      final key = _dayKey(day ?? _clock());
      final nextValue = (updatedCounts[key] ?? 0) + delta;
      if (nextValue <= 0) {
        updatedCounts.remove(key);
      } else {
        updatedCounts[key] = nextValue;
      }
      await sync.setDailyCounts(keys.counter, updatedCounts);
    }

    return HuntStateUpdate(
      startedAt: nextStartedAt,
      caughtAt: nextCaughtAt,
      isCaught: nextCaught,
      caughtGame: nextGame,
      dailyCounts: updatedCounts,
    );
  }

  String _dayKey(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    final local = date.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }
}
