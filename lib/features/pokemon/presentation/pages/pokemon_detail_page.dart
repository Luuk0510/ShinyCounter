import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/counter_controller.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with WidgetsBindingObserver {
  late final CounterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CounterController(
      pokemon: widget.pokemon,
      sync: context.read(),
      toggleCaughtUseCase: context.read(),
    );
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
    final result = await showModalBottomSheet<_EditSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _EditCountersSheet(
          counter: _controller.counter,
          startedAt: _controller.startedAt,
          caughtAt: _controller.caughtAt,
        );
      },
    );

    if (result == null) return;
    if (result.counter != null && result.counter != _controller.counter) {
      await _controller.setCounterManual(result.counter!);
    }
    if (result.startedChanged) {
      await _controller.setStartedAtDate(result.startedAt);
    }
    if (result.caughtChanged) {
      await _controller.setCaughtAtDate(result.caughtAt);
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
            child: Container(color: colors.surface.withOpacity(0.82)),
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
          final bottomPadding =
              mediaQuery.padding.bottom + bottomInset + (isPortrait ? 110 : 24);

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
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.catching_pokemon,
                                    size: 140,
                                  ),
                                )
                              : Image.asset(
                                  widget.pokemon.imagePath,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.catching_pokemon,
                                    size: 140,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: _toggleCaught,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _controller.isCaught
                                  ? colors.tertiary
                                  : colors.secondary,
                              foregroundColor: _controller.isCaught
                                  ? colors.onTertiary
                                  : colors.onSecondary,
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
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  child: _HuntDatesCard(
                                    colors: colors,
                                    startedAt: _controller.startedAt,
                                    caughtAt: _controller.caughtAt,
                                    formatter: _formatDate,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                  ),
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
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
    final valueStyle = TextStyle(
      color: colors.onSurface,
      fontSize: 17,
      fontWeight: FontWeight.w800,
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
          _HuntCell(
            label: 'Start',
            value: formatter(startedAt),
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          const SizedBox(width: 18),
          _HuntCell(
            label: 'Catch',
            value: formatter(caughtAt),
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
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
        height: 210,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.35)),
        ),
        child: Text(
          'Nog geen tellingen',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      height: 210,
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
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Aantal',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.outlineVariant.withOpacity(0.25),
          ),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => Divider(
                height: 16,
                thickness: 1,
                color: colors.outlineVariant.withOpacity(0.25),
              ),
              itemCount: entries.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditSheetResult {
  const _EditSheetResult({
    this.counter,
    this.startedAt,
    this.caughtAt,
    this.startedChanged = false,
    this.caughtChanged = false,
  });

  final int? counter;
  final DateTime? startedAt;
  final DateTime? caughtAt;
  final bool startedChanged;
  final bool caughtChanged;
}

class _EditCountersSheet extends StatefulWidget {
  const _EditCountersSheet({
    required this.counter,
    required this.startedAt,
    required this.caughtAt,
  });

  final int counter;
  final DateTime? startedAt;
  final DateTime? caughtAt;

  @override
  State<_EditCountersSheet> createState() => _EditCountersSheetState();
}

class _EditCountersSheetState extends State<_EditCountersSheet> {
  late final TextEditingController _counterCtrl = TextEditingController(
    text: '${widget.counter}',
  );
  DateTime? _start;
  DateTime? _catch;
  bool _startChanged = false;
  bool _catchChanged = false;

  @override
  void initState() {
    super.initState();
    _start = widget.startedAt;
    _catch = widget.caughtAt;
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aanpassen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _counterCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Counter',
              hintText: 'Voer een getal in',
              labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              hintStyle: TextStyle(fontSize: 17),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _DateRow(
            label: 'Start',
            value: _start,
            onPick: () => _pickDateTime(_start).then((value) {
              if (value != null) {
                setState(() {
                  _start = value;
                  _startChanged = true;
                });
              }
            }),
            onClear: () {
              setState(() {
                _start = null;
                _startChanged = true;
              });
            },
          ),
          const SizedBox(height: 12),
          _DateRow(
            label: 'Catch',
            value: _catch,
            onPick: () => _pickDateTime(_catch).then((value) {
              if (value != null) {
                setState(() {
                  _catch = value;
                  _catchChanged = true;
                });
              }
            }),
            onClear: () {
              setState(() {
                _catch = null;
                _catchChanged = true;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary, width: 1.4),
                    backgroundColor: colors.primary.withOpacity(0.08),
                  ),
                  child: const Text(
                    'Annuleren',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: const Text(
                    'Opslaan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submit() {
    final parsed = int.tryParse(_counterCtrl.text.trim());
    if (parsed == null || parsed < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voer een geldige counter in')),
      );
      return;
    }
    Navigator.of(context).pop(
      _EditSheetResult(
        counter: parsed,
        startedAt: _start,
        caughtAt: _catch,
        startedChanged: _startChanged,
        caughtChanged: _catchChanged,
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    String two(int v) => v.toString().padLeft(2, '0');
    final formatted = value == null
        ? '--'
        : '${two(value!.day)}-${two(value!.month)}-${value!.year} ${two(value!.hour)}:${two(value!.minute)}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatted,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.edit_calendar), onPressed: onPick),
        IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
      ],
    );
  }
}
