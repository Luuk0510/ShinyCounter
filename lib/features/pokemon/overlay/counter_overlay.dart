import 'dart:async';
import 'dart:convert';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';
import 'package:shiny_counter/features/pokemon/overlay/widgets/round_control.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
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
  CounterKeys? _keys;
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
    final keys = CounterKeys.fromCounterKey(message.counterKey);
    final dates = await _loadHuntDatesFor(keys);
    if (!mounted) return;
    setState(() {
      _name = message.name;
      _keys = keys;
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
    if (!_enabled) return;
    final keys = _keys;
    if (keys == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final current = prefs.getInt(keys.counter) ?? _count;
    var next = current + delta;
    if (next < 0) next = 0;
    final appliedDelta = next - current;

    final wasZero = current <= 0;
    DateTime? startedAt = _startedAt;
    DateTime? caughtAt = _caughtAt;

    if (wasZero && next > 0) {
      startedAt = DateTime.now();
      caughtAt = null;
      await prefs.setString(keys.startedAt, startedAt.toIso8601String());
      await prefs.remove(keys.caughtAt);
    } else if (next == 0) {
      startedAt = null;
      caughtAt = null;
      await prefs.remove(keys.startedAt);
      await prefs.remove(keys.caughtAt);
    }

    await prefs.setInt(keys.counter, next);
    if (appliedDelta != 0) {
      await _updateDailyCounts(prefs, keys, appliedDelta);
    }
    if (!mounted) return;
    setState(() {
      _count = next;
      _startedAt = startedAt;
      _caughtAt = caughtAt;
    });
    final message = CounterOverlayMessage(
      name: _name,
      counterKey: keys.counter,
      count: next,
      enabled: _enabled,
    );
    FlutterOverlayWindow.shareData(message.serialize());
  }

  Future<(DateTime?, DateTime?)> _loadHuntDatesFor(CounterKeys keys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final started = prefs.getString(keys.startedAt);
    final caught = prefs.getString(keys.caughtAt);
    return (
      started != null ? DateTime.tryParse(started) : null,
      caught != null ? DateTime.tryParse(caught) : null,
    );
  }

  Future<void> _updateDailyCounts(
    SharedPreferences prefs,
    CounterKeys keys,
    int delta,
  ) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final raw = prefs.getString(keys.dailyCounts);
    final map = raw == null
        ? <String, int>{}
        : Map<String, int>.from(jsonDecode(raw) as Map);
    map[today] = (map[today] ?? 0) + delta;
    await prefs.setString(keys.dailyCounts, jsonEncode(map));
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF1E1E1E).withValues(alpha: 0.9);
    final borderRadius = BorderRadius.circular(AppSizes.overlayCorner);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppSizes.overlayBlur,
                sigmaY: AppSizes.overlayBlur,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.overlayPadH,
                  vertical: AppSizes.overlayPadV,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: borderRadius,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RoundControl(
                            icon: Icons.remove,
                            onTap: _enabled ? () => _bump(-1) : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _name,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: AppSizes.overlayNameSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$_count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppSizes.overlayCountSize,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RoundControl(
                            icon: Icons.add,
                            onTap: _enabled ? () => _bump(1) : null,
                          ),
                          IconButton(
                            constraints: const BoxConstraints.tightFor(
                              width: AppSizes.overlayIconButtonSize,
                              height: AppSizes.overlayIconButtonSize,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            icon: const Icon(Icons.close),
                            color: Colors.white70,
                            iconSize: AppSizes.overlayCloseSize,
                            onPressed: () async {
                              await FlutterOverlayWindow.closeOverlay();
                              await FlutterOverlayWindow.shareData('closed');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
