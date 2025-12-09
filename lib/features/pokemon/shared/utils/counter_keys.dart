class CounterKeys {
  CounterKeys.fromId(String id)
    : _id = id.toLowerCase(),
      _counterKey = 'counter_${id.toLowerCase()}';

  CounterKeys.fromCounterKey(String counterKey)
    : _counterKey = counterKey,
      _id = _extractId(counterKey);

  final String _id;
  final String _counterKey;

  String get counter => _counterKey;
  String get caught => 'caught_$_id';
  String get startedAt => '${_counterKey}_startedAt';
  String get caughtAt => '${_counterKey}_caughtAt';
  String get caughtGame => '${_counterKey}_caughtGame';
  String get dailyCounts => '${_counterKey}_dailyCounts';

  static String _extractId(String counterKey) {
    const prefix = 'counter_';
    if (counterKey.startsWith(prefix)) {
      return counterKey.substring(prefix.length);
    }
    return counterKey;
  }
}
