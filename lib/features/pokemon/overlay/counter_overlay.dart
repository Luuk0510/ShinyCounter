import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';
import 'package:shiny_counter/features/pokemon/overlay/widgets/round_control.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/shared/services/hunt_state_service.dart';
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
  final HuntStateService _huntState = HuntStateService();

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
    final sync = await CounterSyncService.instance();
    final state = await sync.loadState(keys.counter, keys.caught);
    final current = state.count;
    var next = current + delta;
    if (next < 0) next = 0;
    final update = await _huntState.applyCountChange(
      keys: keys,
      sync: sync,
      previousCount: current,
      nextCount: next,
      isCaught: state.isCaught,
      startedAt: state.startedAt,
      caughtAt: state.caughtAt,
      caughtGame: state.caughtGame,
      dailyCounts: state.dailyCounts,
    );
    await sync.setCounter(keys.counter, next);
    if (!mounted) return;
    setState(() {
      _count = next;
      _startedAt = update.startedAt;
      _caughtAt = update.caughtAt;
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
    final sync = await CounterSyncService.instance();
    final state = await sync.loadState(keys.counter, keys.caught);
    return (state.startedAt, state.caughtAt);
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
