import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/dialogs.dart';

const EdgeInsets dialogActionsPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.lg,
  vertical: AppSpacing.sm,
);

const EdgeInsets dialogButtonPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.xl,
  vertical: AppSpacing.sm,
);

List<Widget> dialogActions({
  required BuildContext context,
  required String cancelLabel,
  required String confirmLabel,
  required VoidCallback onCancel,
  required VoidCallback? onConfirm,
  bool destructive = false,
  Key? cancelKey,
  Key? confirmKey,
  EdgeInsets buttonPadding = dialogButtonPadding,
  FontWeight fontWeight = FontWeight.w700,
}) {
  final colors = Theme.of(context).colorScheme;
  return [
    TextButton(
      key: cancelKey,
      onPressed: onCancel,
      style: AppButtonStyles.primaryOutline(
        colors,
        padding: buttonPadding,
        useLighter: true,
      ),
      child: Text(
        cancelLabel,
        style: AppTypography.button.copyWith(fontWeight: fontWeight),
      ),
    ),
    const SizedBox(width: AppSpacing.sm),
    ElevatedButton(
      key: confirmKey,
      onPressed: onConfirm,
      style: destructive
          ? AppButtonStyles.destructiveFilled(colors, padding: buttonPadding)
          : AppButtonStyles.primaryFilled(colors, padding: buttonPadding),
      child: Text(
        confirmLabel,
        style: AppTypography.button.copyWith(fontWeight: fontWeight),
      ),
    ),
  ];
}

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required String cancelLabel,
  required String confirmLabel,
  bool destructive = false,
}) {
  return showScaledDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Theme.of(dialogContext).cardColor,
      surfaceTintColor: Colors.transparent,
      title: title,
      content: content,
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: dialogActionsPadding,
      actions: dialogActions(
        context: dialogContext,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        destructive: destructive,
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    ),
  );
}
