class DailyCountSeed {
  const DailyCountSeed({required this.date, required this.count});

  final DateTime date;
  final int count;
}

class DailyCountsService {
  const DailyCountsService();

  List<DailyCountSeed> buildSeeds(
    Map<String, int> dailyCounts, {
    DateTime? now,
  }) {
    if (dailyCounts.isEmpty) {
      return [DailyCountSeed(date: now ?? DateTime.now(), count: 0)];
    }

    final entries = dailyCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final fallback = now ?? DateTime.now();
    return entries
        .map(
          (entry) => DailyCountSeed(
            date: DateTime.tryParse(entry.key) ?? fallback,
            count: entry.value,
          ),
        )
        .toList();
  }
}
