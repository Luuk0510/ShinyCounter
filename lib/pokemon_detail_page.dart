import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_overlay_window/src/models/overlay_position.dart';
import 'overlay/counter_overlay_message.dart';
import 'services/counter_sync_service.dart';

import 'pokemon.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> with WidgetsBindingObserver {
  int _counter = 0;
  bool _isCaught = false;
  bool _pillActive = false;
  StreamSubscription<dynamic>? _overlaySub;
  static final Stream<dynamic> _overlayStream = CounterSyncService.overlayStream;
  Timer? _pollTimer;
  CounterSyncService? _sync;

  CounterOverlayMessage get _overlayPayload => CounterOverlayMessage(
        name: widget.pokemon.name,
        counterKey: _counterKey,
        count: _counter,
        enabled: !_isCaught,
      );

  String get _counterKey => 'counter_${widget.pokemon.name.toLowerCase()}';
  String get _caughtKey => 'caught_${widget.pokemon.name.toLowerCase()}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _overlaySub = _overlayStream.listen((data) {
      if (!mounted) return;
      if (data is String) {
        if (data == 'closed') {
          setState(() => _pillActive = false);
          _pollTimer?.cancel();
          return;
        }
        if (data.startsWith('counter:')) {
          _handleOverlayMessage(data);
        }
      }
    });
    _initState();
  }

  @override
  void dispose() {
    _overlaySub?.cancel();
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadState();
    }
  }

  Future<void> _initState() async {
    _sync = await CounterSyncService.instance();
    await _loadState();
    _startPeriodicSync();
  }

  Future<void> _loadState() async {
    final svc = await _getService();
    final state = await svc.loadState(_counterKey, _caughtKey);
    setState(() {
      _counter = state.count;
      _isCaught = state.isCaught;
    });
  }

  Future<void> _persistCounter() async {
    final svc = await _getService();
    await svc.setCounter(_counterKey, _counter);
  }

  Future<void> _hapticTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> _increment() async {
    if (_isCaught) return;
    await _hapticTap();
    setState(() => _counter++);
    await _persistCounter();
    await _updatePill();
  }

  Future<void> _decrement() async {
    if (_isCaught || _counter == 0) return;
    await _hapticTap();
    setState(() => _counter--);
    await _persistCounter();
    await _updatePill();
  }

  Future<void> _toggleCaught() async {
    await _hapticTap();
    final svc = await _getService();
    setState(() {
      _isCaught = !_isCaught;
    });
    await svc.setCaught(_caughtKey, _isCaught);
    await _updatePill();
  }

  Future<void> _showEditDialog() async {
    final controller = TextEditingController(text: '$_counter');
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Counter bewerken'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Waarde',
              hintText: 'Voer een getal in',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value != null && value >= 0) {
                  _hapticTap();
                  Navigator.of(context).pop(value);
                }
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _counter = result;
        _isCaught = false;
      });
      await _persistCounter();
      final svc = await _getService();
      await svc.setCaught(_caughtKey, _isCaught);
      await _updatePill();
    }
  }

  Future<void> _togglePill() async {
    final hasPerm = await FlutterOverlayWindow.isPermissionGranted();
    if (!hasPerm) {
      final requested = await FlutterOverlayWindow.requestPermission();
      if (requested != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Overlay permissie nodig voor mini-counter')),
          );
        }
        return;
      }
    }
    if (_pillActive) {
      await _updatePill();
      return;
    }

    final svc = await _getService();
    await svc.showOverlay(
      _overlayPayload,
      height: 180,
      width: 900,
      start: const OverlayPosition(0, 120),
    );
    if (mounted) setState(() => _pillActive = true);
  }

  Future<void> _updatePill() async {
    if (!_pillActive) return;
    final svc = await _getService();
    await svc.shareToOverlay(_overlayPayload);
  }

  Future<void> _handleOverlayMessage(String data) async {
    final message = CounterOverlayMessage.tryParse(data);
    if (message == null || message.counterKey != _counterKey) return;

    if (!mounted) return;
    setState(() {
      _counter = message.count;
      _isCaught = !message.enabled;
    });
    await _persistCounter();
    final svc = await _getService();
    await svc.setCaught(_caughtKey, _isCaught);
  }

  void _startPeriodicSync() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 400), (_) async {
      final svc = await _getService();
      final state = await svc.loadState(_counterKey, _caughtKey);
      if (!mounted) return;
      if (state.count != _counter || state.isCaught != _isCaught) {
        setState(() {
          _counter = state.count;
          _isCaught = state.isCaught;
        });
      }
    });
  }

  Future<CounterSyncService> _getService() async {
    _sync ??= await CounterSyncService.instance();
    return _sync!;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: colors.surface.withOpacity(0.82),
            ),
          ),
        ),
        title: Text(
          widget.pokemon.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Counter bewerken',
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'Mini-counter openen',
            onPressed: _togglePill,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mediaQuery = MediaQuery.of(context);
          final bottomInset = mediaQuery.viewInsets.bottom;
          final isPortrait = mediaQuery.orientation == Orientation.portrait;
          final bottomPadding = mediaQuery.padding.bottom + bottomInset + (isPortrait ? 110 : 24);

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: widget.pokemon.isLocalFile && !kIsWeb
                              ? Image.file(
                                  File(widget.pokemon.imagePath),
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.catching_pokemon, size: 140),
                                )
                              : Image.asset(
                                  widget.pokemon.imagePath,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.catching_pokemon, size: 140),
                                ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: _toggleCaught,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isCaught ? Colors.green.shade600 : colors.secondary,
                              foregroundColor:
                                  _isCaught ? Colors.white : colors.onSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                _isCaught ? 'Caught' : 'Catch',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_counter',
                            style: textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _RoundIconButton(
                                icon: Icons.remove,
                                onPressed: _decrement,
                                background: colors.primaryContainer,
                                foreground: colors.onPrimaryContainer,
                                enabled: !_isCaught,
                              ),
                              const SizedBox(width: 28),
                              _RoundIconButton(
                                icon: Icons.add,
                                onPressed: _increment,
                                background: colors.primaryContainer,
                                foreground: colors.onPrimaryContainer,
                                enabled: !_isCaught,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color effectiveBg = enabled ? background : colors.surfaceVariant;
    final Color effectiveFg = enabled ? foreground : colors.onSurfaceVariant;

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBg,
        foregroundColor: effectiveFg,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(18),
        minimumSize: const Size(72, 72),
      ),
      child: Icon(icon, size: 32),
    );
  }
}
