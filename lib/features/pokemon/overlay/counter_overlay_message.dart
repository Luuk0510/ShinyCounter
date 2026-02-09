import 'dart:convert';

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

  String serialize() => jsonEncode({
    'type': 'counter',
    'name': name,
    'counterKey': counterKey,
    'count': count,
    'enabled': enabled,
  });

  static CounterOverlayMessage? tryParse(String raw) {
    final parsedJson = _tryParseJson(raw);
    if (parsedJson != null) return parsedJson;
    return _tryParseLegacy(raw);
  }

  static CounterOverlayMessage? _tryParseJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final type = decoded['type'];
      if (type != null && type != 'counter') return null;
      final name = decoded['name']?.toString();
      final counterKey = decoded['counterKey']?.toString();
      final count = _parseCount(decoded['count']);
      final enabled = _parseEnabled(decoded['enabled']);
      if (name == null ||
          counterKey == null ||
          count == null ||
          enabled == null) {
        return null;
      }
      return CounterOverlayMessage(
        name: name,
        counterKey: counterKey,
        count: count,
        enabled: enabled,
      );
    } catch (_) {
      return null;
    }
  }

  static CounterOverlayMessage? _tryParseLegacy(String raw) {
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

  static int? _parseCount(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static bool? _parseEnabled(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    final text = value?.toString().toLowerCase();
    if (text == '1' || text == 'true') return true;
    if (text == '0' || text == 'false') return false;
    return null;
  }
}
