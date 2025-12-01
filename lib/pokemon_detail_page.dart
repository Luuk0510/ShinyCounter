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
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  child: _HuntDatesCard(
                                    colors: colors,
                                    startedAt: _controller.startedAt,
                                    caughtAt: _controller.caughtAt,
                                    formatter: _formatDate,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 200),
                                  child: _DailyCountsList(
                                    colors: colors,
                                    dailyCounts: _controller.dailyCounts,
                                    dayFormatter: _formatDayKey,
                                  ),
                                ),
                              ],
                            ),
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

  String _formatDate(DateTime? value) {
    if (value == null) return '--';
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.day)}-${two(local.month)}-${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  String _formatDayKey(String key) {
    final parsed = DateTime.tryParse(key);
    if (parsed == null) return key;
    String two(int v) => v.toString().padLeft(2, '0');
    final local = parsed.toLocal();
    return '${two(local.day)}-${two(local.month)}-${local.year}';
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

class _HuntDatesCard extends StatelessWidget {
  const _HuntDatesCard({
    required this.colors,
    required this.startedAt,
    required this.caughtAt,
    required this.formatter,
  });

  final ColorScheme colors;
  final DateTime? startedAt;
  final DateTime? caughtAt;
  final String Function(DateTime?) formatter;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = TextStyle(
      color: colors.onSurface,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HuntCell(label: 'Start', value: formatter(startedAt), labelStyle: labelStyle, valueStyle: valueStyle),
          const SizedBox(width: 18),
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
        const SizedBox(height: 4),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _DailyCountsList extends StatelessWidget {
  const _DailyCountsList({
    required this.colors,
    required this.dailyCounts,
    required this.dayFormatter,
  });

  final ColorScheme colors;
  final Map<String, int> dailyCounts;
  final String Function(String) dayFormatter;

  @override
  Widget build(BuildContext context) {
    final entries = dailyCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    if (entries.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.35)),
        ),
        child: Text(
          'Nog geen tellingen',
          style: TextStyle(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Datum',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Aantal',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayFormatter(entry.key),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) =>
                  const Divider(height: 16, thickness: 1, color: Colors.black12),
              itemCount: entries.length,
            ),
          ),
        ],
      ),
    );
  }
}
