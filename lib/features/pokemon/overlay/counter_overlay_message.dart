class CounterOverlayMessage {
  const CounterOverlayMessage({
    required this.name,
    required this.counterKey,
    required this.count,
    required this.enabled,
  });

  final String name;
  final String counterKey;
  final int count;
  final bool enabled;

  String serialize() => 'counter:$name:$counterKey:$count:${enabled ? 1 : 0}';

  static CounterOverlayMessage? tryParse(String raw) {
    if (!raw.startsWith('counter:')) return null;
    final parts = raw.split(':');
    if (parts.length < 5) return null;
    final count = int.tryParse(parts[3]);
    if (count == null) return null;
    return CounterOverlayMessage(
      name: parts[1],
      counterKey: parts[2],
      count: count,
      enabled: parts[4] == '1',
    );
  }
}
