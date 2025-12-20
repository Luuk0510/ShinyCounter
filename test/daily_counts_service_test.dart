import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/services/daily_counts_service.dart';

void main() {
  test('buildSeeds returns fallback date for empty counts', () {
    final service = DailyCountsService();
    final now = DateTime(2024, 1, 2);
    final seeds = service.buildSeeds({}, now: now);
    expect(seeds, hasLength(1));
    expect(seeds.first.date, now);
    expect(seeds.first.count, 0);
  });

  test('buildSeeds falls back on invalid date keys', () {
    final service = DailyCountsService();
    final now = DateTime(2024, 2, 1);
    final seeds = service.buildSeeds({'bad-date': 3}, now: now);
    expect(seeds.single.date, now);
    expect(seeds.single.count, 3);
  });

  test('buildSeeds sorts entries descending by key', () {
    final service = DailyCountsService();
    final seeds = service.buildSeeds({'2024-01-02': 1, '2024-01-03': 2});
    expect(seeds.first.count, 2);
    expect(seeds.last.count, 1);
  });
}
