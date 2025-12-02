import 'dart:async';
import 'dart:convert';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SharedPreferencesAndroid.registerWith();
  } catch (_) {}
  runApp(const _OverlayApp());
}

class _OverlayApp extends StatefulWidget {
  const _OverlayApp();

  @override
  State<_OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<_OverlayApp> {
  StreamSubscription<dynamic>? _sub;
  String _name = 'Pokémon';
  String _counterKey = '';
  int _count = 0;
  bool _enabled = true;
  DateTime? _startedAt;
  DateTime? _caughtAt;

  @override
  void initState() {
    super.initState();
    _sub = FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is String) {
        _parseContent(data);
      }
    });
  }

  Future<void> _parseContent(String content) async {
    final message = CounterOverlayMessage.tryParse(content);
    if (message == null) return;
    final dates = await _loadHuntDatesFor(message.counterKey);
    if (!mounted) return;
    setState(() {
      _name = message.name;
      _counterKey = message.counterKey;
      _count = message.count;
      _enabled = message.enabled;
      _startedAt = dates.$1;
      _caughtAt = dates.$2;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _bump(int delta) async {
    if (!_enabled || _counterKey.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final current = prefs.getInt(_counterKey) ?? _count;
    var next = current + delta;
    if (next < 0) next = 0;
    final appliedDelta = next - current;

    final wasZero = current <= 0;
    DateTime? startedAt = _startedAt;
    DateTime? caughtAt = _caughtAt;

    if (wasZero && next > 0) {
      startedAt = DateTime.now();
      caughtAt = null;
      await prefs.setString(_startedAtKey, startedAt.toIso8601String());
      await prefs.remove(_caughtAtKey);
    } else if (next == 0) {
      startedAt = null;
      caughtAt = null;
      await prefs.remove(_startedAtKey);
      await prefs.remove(_caughtAtKey);
    }

    await prefs.setInt(_counterKey, next);
    if (appliedDelta != 0) {
      await _updateDailyCounts(prefs, appliedDelta);
    }
    if (!mounted) return;
    setState(() {
      _count = next;
      _startedAt = startedAt;
      _caughtAt = caughtAt;
    });
    final message = CounterOverlayMessage(
      name: _name,
      counterKey: _counterKey,
      count: next,
      enabled: _enabled,
    );
    FlutterOverlayWindow.shareData(message.serialize());
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF1E1E1E).withOpacity(0.9);
    final borderRadius = BorderRadius.circular(150);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: borderRadius,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.white,
                          onPressed: _enabled ? () => _bump(-1) : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _name,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$_count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                          onPressed: _enabled ? () => _bump(1) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.white70,
                          onPressed: () async {
                            await FlutterOverlayWindow.closeOverlay();
                            await FlutterOverlayWindow.shareData('closed');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _HuntDatesTable(
                      startedAt: _startedAt,
                      caughtAt: _caughtAt,
                      formatter: _formatDate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '--';
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.day)}-${two(local.month)}-${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  String get _startedAtKey => '${_counterKey}_startedAt';

  String get _caughtAtKey => '${_counterKey}_caughtAt';

  String get _dailyCountsKey => '${_counterKey}_dailyCounts';

  Future<(DateTime?, DateTime?)> _loadHuntDatesFor(String counterKey) async {
    if (counterKey.isEmpty) return (null, null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final startedRaw = prefs.getString('${counterKey}_startedAt');
    final caughtRaw = prefs.getString('${counterKey}_caughtAt');
    return (_parseDate(startedRaw), _parseDate(caughtRaw));
  }

  DateTime? _parseDate(String? raw) => raw == null ? null : DateTime.tryParse(raw);

  Future<void> _updateDailyCounts(SharedPreferences prefs, int delta) async {
    if (delta == 0) return;
    final key = _dailyCountsKey;
    final current = _readDailyCounts(prefs.getString(key));
    final dayKey = _dayKey(DateTime.now());
    final next = (current[dayKey] ?? 0) + delta;
    if (next <= 0) {
      current.remove(dayKey);
    } else {
      current[dayKey] = next;
    }
    if (current.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, jsonEncode(current));
    }
  }

  Map<String, int> _readDailyCounts(String? raw) {
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map<String, int>((key, value) {
        final k = key.toString();
        final v = value is int ? value : int.tryParse(value.toString()) ?? 0;
        return MapEntry(k, v);
      })..removeWhere((_, v) => v == 0);
    } catch (_) {
      return {};
    }
  }

  String _dayKey(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    final local = date.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }
}

class _HuntDatesTable extends StatelessWidget {
  const _HuntDatesTable({
    required this.startedAt,
    required this.caughtAt,
    required this.formatter,
  });

  final DateTime? startedAt;
  final DateTime? caughtAt;
  final String Function(DateTime?) formatter;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    const valueStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HuntCell(label: 'Start', value: formatter(startedAt), labelStyle: labelStyle, valueStyle: valueStyle),
          const SizedBox(width: 16),
          _HuntCell(label: 'Catch', value: formatter(caughtAt), labelStyle: labelStyle, valueStyle: valueStyle),
        ],
      ),
    );
  }
}

class _HuntCell extends StatelessWidget {
  const _HuntCell({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 2),
        Text(value, style: valueStyle),
      ],
    );
  }
}
