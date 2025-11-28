import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pokemon.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey _contentKey = GlobalKey();
  int _counter = 0;
  bool _isCaught = false;
  bool _needsScroll = true;

  String get _counterKey => 'counter_${widget.pokemon.name.toLowerCase()}';
  String get _caughtKey => 'caught_${widget.pokemon.name.toLowerCase()}';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await _prefs;
    final saved = prefs.getInt(_counterKey);
    final caught = prefs.getBool(_caughtKey) ?? false;
    setState(() {
      _counter = saved ?? 0;
      _isCaught = caught;
    });
  }

  Future<void> _persistCounter() async {
    final prefs = await _prefs;
    await prefs.setInt(_counterKey, _counter);
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
  }

  Future<void> _decrement() async {
    if (_isCaught || _counter == 0) return;
    await _hapticTap();
    setState(() => _counter--);
    await _persistCounter();
  }

  Future<void> _toggleCaught() async {
    await _hapticTap();
    final prefs = await _prefs;
    setState(() {
      _isCaught = !_isCaught;
    });
    await prefs.setBool(_caughtKey, _isCaught);
  }

  Future<void> _showEditDialog() async {
    final controller = TextEditingController(text: '$_counter');
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aantal bewerken'),
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
      final prefs = await _prefs;
      await prefs.setBool(_caughtKey, _isCaught);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pokemon.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Counter bewerken',
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ctx = _contentKey.currentContext;
            final box = ctx?.findRenderObject() as RenderBox?;
            if (box != null) {
              final contentHeight = box.size.height + bottomInset;
              final needsScroll = contentHeight > constraints.maxHeight;
              if (needsScroll != _needsScroll) {
                setState(() => _needsScroll = needsScroll);
              }
            }
          });

          final content = Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
            child: KeyedSubtree(
              key: _contentKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          _isCaught ? 'Gevangen' : 'Vangen',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Column(
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );

          if (_needsScroll) {
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: content,
            );
          }
          return content;
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
