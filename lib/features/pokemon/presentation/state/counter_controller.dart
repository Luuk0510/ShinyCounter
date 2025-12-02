import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';

class CounterController extends ChangeNotifier {
  CounterController({
    required this.pokemon,
    CounterSyncService? sync,
    ToggleCaughtUseCase? toggleCaughtUseCase,
  })  : _sync = sync,
        _toggleCaughtUseCase = toggleCaughtUseCase;

  final Pokemon pokemon;
  final int overlayHeight = 200;
  final int overlayWidth = 1000;

  int _counter = 0;
  bool _isCaught = false;
  bool _pillActive = false;
  DateTime? _startedAt;
  DateTime? _caughtAt;
  Map<String, int> _dailyCounts = {};

  late final String _counterKey = 'counter_${pokemon.name.toLowerCase()}';
  late final String _caughtKey = 'caught_${pokemon.name.toLowerCase()}';

  CounterSyncService? _sync;
  ToggleCaughtUseCase? _toggleCaughtUseCase;
  StreamSubscription<dynamic>? _overlaySub;
  Timer? _pollTimer;
  bool _initialized = false;

  int get counter => _counter;
  bool get isCaught => _isCaught;
  bool get pillActive => _pillActive;
  DateTime? get startedAt => _startedAt;
  DateTime? get caughtAt => _caughtAt;
  Map<String, int> get dailyCounts => _dailyCounts;

  CounterOverlayMessage get _message => CounterOverlayMessage(
        name: pokemon.name,
        counterKey: _counterKey,
        count: _counter,
        enabled: !_isCaught,
      );
  bool get _overlaySupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> init() async {
    _sync ??= await CounterSyncService.instance();
    if (_overlaySupported) {
      _overlaySub ??= CounterSyncService.overlayStream.listen(_onOverlayData);
    }
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
    final previous = _counter;
    _counter++;
    final sync = await _getSync();
    await _persist(sync: sync);
    await _handleHuntStartReset(previous, _counter, sync: sync);
    await _applyDailyDelta(1, sync: sync);
    notifyListeners();
    await _updateOverlay();
  }

  Future<void> decrement() async {
    if (_isCaught || _counter == 0) return;
    final previous = _counter;
    _counter--;
    final sync = await _getSync();
    await _persist(sync: sync);
    await _handleHuntStartReset(previous, _counter, sync: sync);
    await _applyDailyDelta(-1, sync: sync);
    notifyListeners();
    await _updateOverlay();
  }

  Future<void> setCounter(int value) async {
    final previous = _counter;
    _counter = value;
    _isCaught = false;
    _caughtAt = null;
    final sync = await _getSync();
    await _persist(sync: sync);
    await _setCaught(false, sync: sync);
    await _handleHuntStartReset(previous, _counter, sync: sync);
    final delta = _counter - previous;
    if (delta != 0) {
      await _applyDailyDelta(delta, sync: sync);
    }
    notifyListeners();
    await _updateOverlay();
  }

  Future<void> setCounterManual(int value) async {
    final previous = _counter;
    _counter = value;
    if (_counter == 0) {
      _isCaught = false;
      _caughtAt = null;
    }
    final sync = await _getSync();
    await _persist(sync: sync);
    if (_counter == 0) {
      await _setCaught(false, sync: sync);
    }
    await _handleHuntStartReset(previous, _counter, sync: sync);
    final delta = _counter - previous;
    if (delta != 0) {
      await _applyDailyDelta(delta, sync: sync);
    }
    notifyListeners();
    await _updateOverlay();
  }

  Future<void> toggleCaught() async {
    _isCaught = !_isCaught;
    final sync = await _getSync();
    await _setCaught(_isCaught, sync: sync);
    if (_isCaught) {
      _caughtAt = DateTime.now();
      await sync.setCaughtAt(_counterKey, _caughtAt);
      if (_startedAt == null && _counter > 0) {
        _startedAt = DateTime.now();
        await sync.setStartedAt(_counterKey, _startedAt);
      }
    } else {
      _caughtAt = null;
      await sync.setCaughtAt(_counterKey, null);
    }
    notifyListeners();
    await _updateOverlay();
  }

  Future<void> setStartedAtDate(DateTime? value) async {
    _startedAt = value;
    final sync = await _getSync();
    await sync.setStartedAt(_counterKey, value);
    await _updateOverlay();
    notifyListeners();
  }

  Future<void> setCaughtAtDate(DateTime? value) async {
    _caughtAt = value;
    final sync = await _getSync();
    await sync.setCaughtAt(_counterKey, value);
    if (value != null) {
      _isCaught = true;
      await _setCaught(true, sync: sync);
    }
    await _updateOverlay();
    notifyListeners();
  }

  Future<void> toggleOverlay() async {
    if (!_overlaySupported) return;

    final hasPerm = await FlutterOverlayWindow.isPermissionGranted();
    if (!hasPerm) {
      final requested = await FlutterOverlayWindow.requestPermission();
      if (requested != true) return;
    }

    final isActive = await FlutterOverlayWindow.isActive();
    if (!isActive && _pillActive) {
      _pillActive = false;
      notifyListeners();
    } else if (isActive) {
      _pillActive = true;
      notifyListeners();
      await _updateOverlay();
      return;
    }

    final sync = await _getSync();
    await sync.showOverlay(
      _message,
      height: overlayHeight,
      width: overlayWidth,
    );
    _pillActive = true;
    notifyListeners();
  }

  Future<void> _loadState() async {
    final sync = await _getSync();
    final state = await sync.loadState(_counterKey, _caughtKey);
    _counter = state.count;
    _isCaught = state.isCaught;
    _startedAt = state.startedAt;
    _caughtAt = state.caughtAt;
    _dailyCounts = state.dailyCounts;
    notifyListeners();
  }

  Future<void> _persist({CounterSyncService? sync}) async {
    final service = sync ?? await _getSync();
    await service.setCounter(_counterKey, _counter);
  }

  Future<void> _setCaught(bool value, {CounterSyncService? sync}) async {
    if (_toggleCaughtUseCase != null) {
      await _toggleCaughtUseCase!.call(_caughtKey, value);
      return;
    }
    final service = sync ?? await _getSync();
    await service.setCaught(_caughtKey, value);
  }

  Future<void> _updateOverlay() async {
    if (!_pillActive || !_overlaySupported) return;
    final sync = await _getSync();
    await sync.shareToOverlay(_message);
  }

  Future<void> _handleHuntStartReset(int previousCount, int nextCount, {CounterSyncService? sync}) async {
    final service = sync ?? await _getSync();
    if (previousCount == 0 && nextCount > 0) {
      final now = DateTime.now();
      _startedAt = now;
      _caughtAt = null;
      await service.setStartedAt(_counterKey, now);
      await service.setCaughtAt(_counterKey, null);
      return;
    }
    if (nextCount == 0) {
      _startedAt = null;
      _caughtAt = null;
      _isCaught = false;
      await service.clearHuntDates(_counterKey);
      await service.setCaught(_caughtKey, false);
    }
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

    final previous = _counter;
    _counter = msg.count;
    _isCaught = !msg.enabled;

    final sync = await _getSync();
    await _persist(sync: sync);
    await _setCaught(_isCaught, sync: sync);
    await _handleHuntStartReset(previous, _counter, sync: sync);
    final delta = _counter - previous;
    if (delta != 0) {
      await _applyDailyDelta(delta, sync: sync);
    }
    notifyListeners();
  }

  void _startPeriodicSync() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final sync = await _getSync();
      final state = await sync.loadState(_counterKey, _caughtKey);
      final changed = state.count != _counter ||
          state.isCaught != _isCaught ||
          !_isSameMoment(state.startedAt, _startedAt) ||
          !_isSameMoment(state.caughtAt, _caughtAt) ||
          !_sameDailyCounts(state.dailyCounts, _dailyCounts);
      if (!changed) return;

      _counter = state.count;
      _isCaught = state.isCaught;
      _startedAt = state.startedAt;
      _caughtAt = state.caughtAt;
      _dailyCounts = state.dailyCounts;
      notifyListeners();
    });
  }

  bool _isSameMoment(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.isAtSameMomentAs(b);
  }

  Future<CounterSyncService> _getSync() async {
    _sync ??= await CounterSyncService.instance();
    return _sync!;
  }

  Future<void> _applyDailyDelta(int delta, {CounterSyncService? sync, DateTime? day}) async {
    if (delta == 0) return;
    final service = sync ?? await _getSync();
    final key = _dayKey(day ?? DateTime.now());
    final updated = Map<String, int>.from(_dailyCounts);
    final next = (updated[key] ?? 0) + delta;
    if (next <= 0) {
      updated.remove(key);
    } else {
      updated[key] = next;
    }
    _dailyCounts = updated;
    await service.setDailyCounts(_counterKey, updated);
  }

  String _dayKey(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    final local = date.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }

  bool _sameDailyCounts(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
