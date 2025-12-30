import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/game_dropdown.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail/date_row.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_field_group.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/safe_area_sheet.dart';

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
    return SafeAreaSheet(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.sheetHandleWidth,
            height: AppSizes.sheetHandleHeight,
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
          DialogFieldGroup(
            children: [
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
              _DateGroup(
                start: _start,
                onStartChanged: (value) => _setDate(
                  value: value,
                  assign: (date) => _start = date,
                  changed: () => _startChanged = true,
                ),
                onStartCleared: () => _setDate(
                  value: null,
                  assign: (date) => _start = date,
                  changed: () => _startChanged = true,
                ),
                catchDate: _catch,
                onCatchChanged: (value) => _setDate(
                  value: value,
                  assign: (date) => _catch = date,
                  changed: () => _catchChanged = true,
                ),
                onCatchCleared: () => _setDate(
                  value: null,
                  assign: (date) => _catch = date,
                  changed: () => _catchChanged = true,
                ),
              ),
              GameDropdown(
                value: _game,
                onChanged: (value) {
                  setState(() {
                    _game = value;
                    _gameChanged = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppButtonStyles.primaryOutline(
                    colors,
                    borderWidth: AppSizes.sheetActionWidth,
                    useLighter: true,
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
                  style: AppButtonStyles.primaryFilled(colors),
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

  void _setDate({
    required DateTime? value,
    required ValueSetter<DateTime?> assign,
    required VoidCallback changed,
  }) {
    setState(() {
      assign(value);
      changed();
    });
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

class _DateGroup extends StatelessWidget {
  const _DateGroup({
    required this.start,
    required this.onStartChanged,
    required this.onStartCleared,
    required this.catchDate,
    required this.onCatchChanged,
    required this.onCatchCleared,
  });

  final DateTime? start;
  final ValueChanged<DateTime?> onStartChanged;
  final VoidCallback onStartCleared;
  final DateTime? catchDate;
  final ValueChanged<DateTime?> onCatchChanged;
  final VoidCallback onCatchCleared;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DateRow(
          label: l10n.huntStart,
          value: start,
          onPick: () => _pickDate(context, start).then((value) {
            if (value != null) onStartChanged(value);
          }),
          onClear: onStartCleared,
        ),
        const SizedBox(height: AppSpacing.md),
        DateRow(
          label: l10n.huntCaught,
          value: catchDate,
          onPick: () => _pickDate(context, catchDate).then((value) {
            if (value != null) onCatchChanged(value);
          }),
          onClear: onCatchCleared,
        ),
      ],
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) async {
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
}
