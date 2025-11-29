import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/counter_controller.dart';

import 'pokemon.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> with WidgetsBindingObserver {
  late final CounterController _controller = CounterController(pokemon: widget.pokemon);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(() => mounted ? setState(() {}) : null);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.init();
    }
  }

  Future<void> _hapticTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> _increment() async {
    if (_controller.isCaught) return;
    await _hapticTap();
    await _controller.increment();
  }

  Future<void> _decrement() async {
    if (_controller.isCaught || _controller.counter == 0) return;
    await _hapticTap();
    await _controller.decrement();
  }

  Future<void> _toggleCaught() async {
    await _hapticTap();
    await _controller.toggleCaught();
  }

  Future<void> _showEditDialog() async {
    final controller = TextEditingController(text: '${_controller.counter}');
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
      await _controller.setCounter(result);
    }
  }

  Future<void> _togglePill() async {
    await _controller.toggleOverlay();
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
                              _controller.isCaught ? Colors.green.shade600 : colors.secondary,
                              foregroundColor:
                                  _controller.isCaught ? Colors.white : colors.onSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                _controller.isCaught ? 'Caught' : 'Catch',
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
                            '${_controller.counter}',
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
                            enabled: !_controller.isCaught,
                          ),
                          const SizedBox(width: 28),
                          _RoundIconButton(
                            icon: Icons.add,
                            onPressed: _increment,
                            background: colors.primaryContainer,
                            foreground: colors.onPrimaryContainer,
                            enabled: !_controller.isCaught,
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
