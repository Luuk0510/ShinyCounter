import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:shiny_counter/features/pokemon/domain/entities/counter_overlay_payload.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';
import 'package:shiny_counter/features/pokemon/shared/services/hunt_state_service.dart';

class CounterController extends ChangeNotifier {
  CounterController({
    required this.pokemon,
    required CounterSync sync,
    ToggleCaughtUseCase? toggleCaughtUseCase,
  }) : _sync = sync,
       _toggleCaughtUseCase = toggleCaughtUseCase,
       _keys = CounterKeys.fromId(pokemon.id);

  final Pokemon pokemon;
  final int overlayHeight = 200;
  final int overlayWidth = 1000;

  int _counter = 0;
  bool _isCaught = false;
  bool _pillActive = false;
  DateTime? _startedAt;
  DateTime? _caughtAt;
  String? _caughtGame;
  Map<String, int> _dailyCounts = {};

  final CounterKeys _keys;
  final HuntStateService _huntState = HuntStateService();

  final CounterSync _sync;
  final ToggleCaughtUseCase? _toggleCaughtUseCase;
  StreamSubscription<dynamic>? _overlaySub;
  Timer? _overlayPoller;

  int get counter => _counter;
  bool get isCaught => _isCaught;
  bool get pillActive => _pillActive;
  DateTime? get startedAt => _startedAt;
  DateTime? get caughtAt => _caughtAt;
  String? get caughtGame => _caughtGame;
  Map<String, int> get dailyCounts => _dailyCounts;

  CounterOverlayPayload get _message => CounterOverlayPayload(
    name: pokemon.name,
    counterKey: _keys.counter,
    count: _counter,
    enabled: !_isCaught,
  );
  bool get _overlaySupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> init() async {
    if (_overlaySupported) {
      _overlaySub ??= _sync.overlayStream.listen(_onOverlayData);
    }
    await _loadState();
  }

  @override
  void dispose() {
    _overlaySub?.cancel();
    _overlayPoller?.cancel();
    super.dispose();
  }

  Future<void> increment() async {
    if (_isCaught) return;
    await _applyCounterUpdate(_counter + 1);
  }

  Future<void> decrement() async {
    if (_isCaught || _counter == 0) return;
    await _applyCounterUpdate(_counter - 1);
  }

  Future<void> setCounter(int value) async {
    await _applyCounterUpdate(value, forceUncaught: true, clearGame: true);
  }

  Future<void> setCounterManual(int value) async {
    await _applyCounterUpdate(value, resetWhenZero: true);
  }

  Future<void> toggleCaught() async {
    _isCaught = !_isCaught;
    final sync = _sync;
    await _setCaught(_isCaught, sync: sync);
    if (_isCaught) {
      _caughtAt = DateTime.now();
      await sync.setCaughtAt(_keys.counter, _caughtAt);
      if (_startedAt == null && _counter > 0) {
        _startedAt = DateTime.now();
        await sync.setStartedAt(_keys.counter, _startedAt);
      }
    } else {
      _caughtAt = null;
      await sync.setCaughtAt(_keys.counter, null);
      // Keep game selection so user doesn't have to reselect after toggling.
    }
    notifyListeners();
    await _updateOverlay();
  }

  Future<void> setStartedAtDate(DateTime? value) async {
    _startedAt = value;
    final sync = _sync;
    await sync.setStartedAt(_keys.counter, value);
    await _updateOverlay();
    notifyListeners();
  }

  Future<void> setCaughtAtDate(DateTime? value) async {
    _caughtAt = value;
    final sync = _sync;
    await sync.setCaughtAt(_keys.counter, value);
    if (value != null) {
      _isCaught = true;
      await _setCaught(true, sync: sync);
      if (_caughtGame != null) {
        await sync.setCaughtGame(_keys.counter, _caughtGame);
      }
    }
    await _updateOverlay();
    notifyListeners();
  }

  Future<void> setCaughtGame(String? game) async {
    _caughtGame = game;
    final sync = _sync;
    await sync.setCaughtGame(_keys.counter, game);
    notifyListeners();
  }

  Future<void> _applyCounterUpdate(
    int nextCount, {
    bool forceUncaught = false,
    bool clearGame = false,
    bool resetWhenZero = false,
  }) async {
    final clamped = nextCount < 0 ? 0 : nextCount;
    final previous = _counter;
    final sync = _sync;

    var nextCaught = _isCaught;
    var nextCaughtAt = _caughtAt;
    var nextCaughtGame = _caughtGame;

    final shouldResetCaught = forceUncaught || (resetWhenZero && clamped == 0);
    if (shouldResetCaught) {
      nextCaught = false;
      nextCaughtAt = null;
      if (clearGame) {
        nextCaughtGame = null;
      }
      await _setCaught(false, sync: sync);
    }

    _counter = clamped;
    _isCaught = nextCaught;
    _caughtAt = nextCaughtAt;
    _caughtGame = nextCaughtGame;

    await _persist(sync: sync);
    if (clearGame) {
      await sync.setCaughtGame(_keys.counter, null);
    }

    final update = await _huntState.applyCountChange(
      keys: _keys,
      sync: sync,
      previousCount: previous,
      nextCount: clamped,
      isCaught: _isCaught,
      startedAt: _startedAt,
      caughtAt: _caughtAt,
      caughtGame: _caughtGame,
      dailyCounts: _dailyCounts,
    );
    _startedAt = update.startedAt;
    _caughtAt = update.caughtAt;
    _isCaught = update.isCaught;
    _caughtGame = update.caughtGame;
    _dailyCounts = update.dailyCounts;
    notifyListeners();
    await _updateOverlay();
  }

  Future<void> toggleOverlay() async {
    if (!_overlaySupported) return;

    final sync = _sync;
    final isActive = await sync.ensureOverlay(
      _message,
      height: overlayHeight,
      width: overlayWidth,
    );
    _pillActive = isActive;
    if (_pillActive) {
      _startOverlayPoller();
    }
    notifyListeners();
  }

  Future<void> _loadState() async {
    final sync = _sync;
    final state = await sync.loadState(_keys.counter, _keys.caught);
    _counter = state.count;
    _isCaught = state.isCaught;
    _startedAt = state.startedAt;
    _caughtAt = state.caughtAt;
    _caughtGame = state.caughtGame;
    _dailyCounts = state.dailyCounts;
    notifyListeners();
  }

  Future<void> _persist({CounterSync? sync}) async {
    final service = sync ?? _sync;
    await service.setCounter(_keys.counter, _counter);
  }

  Future<void> _setCaught(bool value, {CounterSync? sync}) async {
    final useCase = _toggleCaughtUseCase;
    if (useCase != null) {
      await useCase.call(_keys.caught, value);
      return;
    }
    final service = sync ?? _sync;
    await service.setCaught(_keys.caught, value);
  }

  Future<void> setDailyCounts(Map<String, int> counts) async {
    final cleaned = Map<String, int>.from(counts)
      ..removeWhere((_, value) => value <= 0);
    _dailyCounts = cleaned;
    final sync = _sync;
    await sync.setDailyCounts(_keys.counter, cleaned);
    notifyListeners();
    await _updateOverlay();
  }

  Future<void> _updateOverlay() async {
    if (!_pillActive || !_overlaySupported) return;
    await _sync.shareToOverlay(_message);
  }

  void _onOverlayData(dynamic data) async {
    // Overlay sends back the latest state (or a pin toggle). Keep controller in sync.
    if (data is! String) return;
    if (data == 'closed') {
      _pillActive = false;
      _overlayPoller?.cancel();
      notifyListeners();
      return;
    }

    final msg = CounterOverlayMessage.tryParse(data);
    if (msg == null || msg.counterKey != _keys.counter) return;

    final sync = _sync;
    final state = await sync.loadState(_keys.counter, _keys.caught);
    _counter = state.count;
    _isCaught = state.isCaught;
    _startedAt = state.startedAt;
    _caughtAt = state.caughtAt;
    _caughtGame = state.caughtGame;
    _dailyCounts = state.dailyCounts;
    notifyListeners();
  }

  void _startOverlayPoller() {
    _overlayPoller?.cancel();
    if (!_overlaySupported) return;
    _overlayPoller = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_pillActive) return;
      final sync = _sync;
      final state = await sync.loadState(_keys.counter, _keys.caught);
      final changed =
          state.count != _counter ||
          state.isCaught != _isCaught ||
          state.startedAt != _startedAt ||
          state.caughtAt != _caughtAt ||
          state.caughtGame != _caughtGame ||
          !_sameDailyCounts(state.dailyCounts, _dailyCounts);
      if (!changed) return;
      _counter = state.count;
      _isCaught = state.isCaught;
      _startedAt = state.startedAt;
      _caughtAt = state.caughtAt;
      _caughtGame = state.caughtGame;
      _dailyCounts = state.dailyCounts;
      notifyListeners();
    });
  }

  bool _sameDailyCounts(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
