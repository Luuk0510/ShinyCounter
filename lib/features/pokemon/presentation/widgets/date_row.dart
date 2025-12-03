import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class DateRow extends StatelessWidget {
  const DateRow({
    super.key,
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
        : '${two(value!.day)}-${two(value!.month)}-${value!.year}';
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
              const SizedBox(height: AppSpacing.xs),
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
