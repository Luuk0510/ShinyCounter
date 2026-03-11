import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';

int? parseNonNegativeInt(String raw) {
  final parsed = int.tryParse(raw.trim());
  if (parsed == null || parsed < 0) return null;
  return parsed;
}

void showInvalidCounterSnackBar(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.invalidCounter)));
}
