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
