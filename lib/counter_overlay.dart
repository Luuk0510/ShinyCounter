import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'overlay/counter_overlay_message.dart';

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
    setState(() {
      _name = message.name;
      _counterKey = message.counterKey;
      _count = message.count;
      _enabled = message.enabled;
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
    final current = prefs.getInt(_counterKey) ?? _count;
    var next = current + delta;
    if (next < 0) next = 0;
    await prefs.setInt(_counterKey, next);
    setState(() => _count = next);
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
    final bg = const Color(0xFF1E1E1E).withOpacity(0.8);
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
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Row(
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
