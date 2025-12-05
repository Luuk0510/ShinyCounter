import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/date_row.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/game_dropdown.dart';

class EditSheetResult {
  const EditSheetResult({
    this.counter,
    this.startedAt,
    this.caughtAt,
    this.caughtGame,
    this.startedChanged = false,
    this.caughtChanged = false,
    this.gameChanged = false,
  });

  final int? counter;
  final DateTime? startedAt;
  final DateTime? caughtAt;
  final String? caughtGame;
  final bool startedChanged;
  final bool caughtChanged;
  final bool gameChanged;
}

class EditCountersSheet extends StatefulWidget {
  const EditCountersSheet({
    super.key,
    required this.pokemonName,
    required this.counter,
    required this.startedAt,
    required this.caughtAt,
    required this.caughtGame,
  });

  final String pokemonName;
  final int counter;
  final DateTime? startedAt;
  final DateTime? caughtAt;
  final String? caughtGame;

  @override
  State<EditCountersSheet> createState() => _EditCountersSheetState();
}

class _EditCountersSheetState extends State<EditCountersSheet> {
  late final TextEditingController _counterCtrl = TextEditingController(
    text: '${widget.counter}',
  );
  DateTime? _start;
  DateTime? _catch;
  String? _game;
  bool _startChanged = false;
  bool _catchChanged = false;
  bool _gameChanged = false;

  @override
  void initState() {
    super.initState();
    _start = widget.startedAt;
    _catch = widget.caughtAt;
    _game = widget.caughtGame;
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        top: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.sheetHandleWidthPx,
            height: AppSizes.sheetHandleHeightPx,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.editSheetTitle,
            style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _counterCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.counterLabel,
              hintText: l10n.enterNumberHint,
              labelStyle: const TextStyle(
                fontSize: AppSizes.sheetFieldLabel,
                fontWeight: FontWeight.w700,
              ),
              hintStyle: const TextStyle(fontSize: AppSizes.sheetFieldHint),
            ),
            style: const TextStyle(
              fontSize: AppSizes.sheetFieldText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DateRow(
            label: l10n.huntStart,
            value: _start,
            onPick: () => _pickDate(_start).then((value) {
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
          const SizedBox(height: AppSpacing.md),
          DateRow(
            label: l10n.huntCatch,
            value: _catch,
            onPick: () => _pickDate(_catch).then((value) {
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
          const SizedBox(height: AppSpacing.lg),
          GameDropdown(
            value: _game,
            onChanged: (value) {
              setState(() {
                _game = value;
                _gameChanged = true;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(
                      color: colors.primary,
                      width: AppSizes.sheetActionWidth,
                    ),
                    backgroundColor: colors.primary.withValues(alpha: 0.08),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      fontSize: AppSizes.sheetButtonFont,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                      fontSize: AppSizes.sheetButtonFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime? initial) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }

  void _submit() {
    final parsed = int.tryParse(_counterCtrl.text.trim());
    if (parsed == null || parsed < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.invalidCounter)));
      return;
    }
    Navigator.of(context).pop(
      EditSheetResult(
        counter: parsed,
        startedAt: _start,
        caughtAt: _catch,
        caughtGame: _game,
        startedChanged: _startChanged,
        caughtChanged: _catchChanged,
        gameChanged: _gameChanged,
      ),
    );
  }
}
