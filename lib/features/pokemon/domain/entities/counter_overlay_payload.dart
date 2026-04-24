class CounterOverlayPayload {
  const CounterOverlayPayload({
    required this.name,
    required this.counterKey,
    required this.count,
    required this.enabled,
  });

  final String name;
  final String counterKey;
  final int count;
  final bool enabled;
}
