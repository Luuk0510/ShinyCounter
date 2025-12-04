import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class EditDailyCountsSheet extends StatefulWidget {
  const EditDailyCountsSheet({
    super.key,
    required this.dailyCounts,
    required this.dayFormatter,
  });

  final Map<String, int> dailyCounts;
  final String Function(String) dayFormatter;

  @override
  State<EditDailyCountsSheet> createState() => _EditDailyCountsSheetState();
}

class _EditDailyCountsSheetState extends State<EditDailyCountsSheet> {
  final List<_RowData> _rows = [];

  @override
  void initState() {
    super.initState();
    final entries = widget.dailyCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    if (entries.isEmpty) {
      _rows.add(_RowData(DateTime.now(), TextEditingController(text: '0')));
    } else {
      for (final entry in entries) {
        _rows.add(
          _RowData(
            DateTime.tryParse(entry.key) ?? DateTime.now(),
            TextEditingController(text: '${entry.value}'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.controller.dispose();
    }
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                l10n.editSheetTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => _buildRow(context, index),
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemCount: _rows.length,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                onPressed: _addRow,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary, width: 1.3),
                  backgroundColor: colors.primary.withValues(alpha: 0.08),
                ),
              label: Text(
                  l10n.addCountRow,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary, width: 1.4),
                      backgroundColor: colors.primary.withValues(alpha: 0.08),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final row = _rows[index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(index),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.md,
              ),
              side: BorderSide(color: colors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.dayFormatter(_dayKey(row.date)),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 110,
          child: TextField(
            controller: row.controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.countLabel,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _removeRow(index),
          tooltip: l10n.manageDeleteTooltip,
          icon: const Icon(Icons.delete_outline),
          color: colors.error,
        ),
      ],
    );
  }

  Future<void> _pickDate(int index) async {
    final current = _rows[index].date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _rows[index] = _rows[index].copyWith(
        date: DateTime(picked.year, picked.month, picked.day),
      );
    });
  }

  Future<void> _addRow() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final count = await _askForCount();
    if (count == null) return;

    setState(() {
      _rows.add(
        _RowData(
          DateTime(pickedDate.year, pickedDate.month, pickedDate.day),
          TextEditingController(text: '$count'),
        ),
      );
    });
  }

  Future<int?> _askForCount() async {
    final controller = TextEditingController(text: '0');
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(context.l10n.countLabel),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: context.l10n.enterNumberHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: colors.primary),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed == null || parsed < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.invalidCounter)),
                  );
                  return;
                }
                Navigator.of(context).pop(parsed);
              },
              style: TextButton.styleFrom(foregroundColor: colors.primary),
              child: Text(context.l10n.save),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  void _removeRow(int index) {
    final removed = _rows.removeAt(index);
    removed.controller.dispose();
    setState(() {});
  }

  void _save() {
    final counts = <String, int>{};
    for (final row in _rows) {
      final parsed = int.tryParse(row.controller.text.trim());
      if (parsed == null || parsed < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.invalidCounter)),
        );
        return;
      }
      if (parsed == 0) continue;
      counts[_dayKey(row.date)] = parsed;
    }
    Navigator.of(context).pop(counts);
  }

  String _dayKey(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    final local = date.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }
}

class _RowData {
  const _RowData(this.date, this.controller);

  final DateTime date;
  final TextEditingController controller;

  _RowData copyWith({DateTime? date}) =>
      _RowData(date ?? this.date, controller);
}
