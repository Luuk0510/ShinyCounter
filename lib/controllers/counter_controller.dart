import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_overlay_window/src/models/overlay_position.dart';

import '../overlay/counter_overlay_message.dart';
import '../pokemon.dart';
import '../services/counter_sync_service.dart';

class CounterController extends ChangeNotifier {
  CounterController({
    required this.pokemon,
    CounterSyncService? sync,
  }) : _sync = sync;

  final Pokemon pokemon;
  final int overlayHeight = 200;
  final int overlayWidth = 1000;

  int _counter = 0;
  bool _isCaught = false;
  bool _pillActive = false;

  late final String _counterKey = 'counter_${pokemon.name.toLowerCase()}';
  late final String _caughtKey = 'caught_${pokemon.name.toLowerCase()}';

  CounterSyncService? _sync;
  StreamSubscription<dynamic>? _overlaySub;
  Timer? _pollTimer;
  bool _initialized = false;

  int get counter => _counter;
  bool get isCaught => _isCaught;
  bool get pillActive => _pillActive;

  CounterOverlayMessage get _message => CounterOverlayMessage(
        name: pokemon.name,
        counterKey: _counterKey,
        count: _counter,
        enabled: !_isCaught,
      );

  Future<void> init() async {
    _sync ??= await CounterSyncService.instance();
    _overlaySub ??= CounterSyncService.overlayStream.listen(_onOverlayData);
    await _loadState();
    if (!_initialized) {
      _startPeriodicSync();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _overlaySub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> increment() async {
    if (_isCaught) return;
    _counter++;
    notifyListeners();
    await _persist();
    await _updateOverlay();
  }

  Future<void> decrement() async {
    if (_isCaught || _counter == 0) return;
    _counter--;
    notifyListeners();
    await _persist();
    await _updateOverlay();
  }

  Future<void> setCounter(int value) async {
    _counter = value;
    _isCaught = false;
    notifyListeners();
    await _persist();
    await _setCaught(false);
    await _updateOverlay();
  }

  Future<void> toggleCaught() async {
    _isCaught = !_isCaught;
    notifyListeners();
    await _setCaught(_isCaught);
    await _updateOverlay();
  }

  Future<void> toggleOverlay() async {
    final hasPerm = await FlutterOverlayWindow.isPermissionGranted();
    if (!hasPerm) {
      final requested = await FlutterOverlayWindow.requestPermission();
      if (requested != true) return;
    }
    if (_pillActive) {
      await _updateOverlay();
      return;
    }

    final sync = await _getSync();
    await sync.showOverlay(
      _message,
      height: overlayHeight,
      width: overlayWidth,
      start: const OverlayPosition(0, 120),
    );
    _pillActive = true;
    notifyListeners();
  }

  Future<void> _loadState() async {
    final sync = await _getSync();
    final state = await sync.loadState(_counterKey, _caughtKey);
    _counter = state.count;
    _isCaught = state.isCaught;
    notifyListeners();
  }

  Future<void> _persist() async {
    final sync = await _getSync();
    await sync.setCounter(_counterKey, _counter);
  }

  Future<void> _setCaught(bool value) async {
    final sync = await _getSync();
    await sync.setCaught(_caughtKey, value);
  }

  Future<void> _updateOverlay() async {
    if (!_pillActive) return;
    final sync = await _getSync();
    await sync.shareToOverlay(_message);
  }

  void _onOverlayData(dynamic data) async {
    if (data is! String) return;
    if (data == 'closed') {
      _pillActive = false;
      notifyListeners();
      return;
    }

    final msg = CounterOverlayMessage.tryParse(data);
    if (msg == null || msg.counterKey != _counterKey) return;

    _counter = msg.count;
    _isCaught = !msg.enabled;
    notifyListeners();

    await _persist();
    await _setCaught(_isCaught);
  }

  void _startPeriodicSync() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 400), (_) async {
      final sync = await _getSync();
      final state = await sync.loadState(_counterKey, _caughtKey);
      if (state.count != _counter || state.isCaught != _isCaught) {
        _counter = state.count;
        _isCaught = state.isCaught;
        notifyListeners();
      }
    });
  }

  Future<CounterSyncService> _getSync() async {
    _sync ??= await CounterSyncService.instance();
    return _sync!;
  }
}
