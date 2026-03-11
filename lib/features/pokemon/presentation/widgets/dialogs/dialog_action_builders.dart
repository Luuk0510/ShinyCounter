import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class DialogActionBar extends StatelessWidget {
  const DialogActionBar({
    super.key,
    required this.colors,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.cancelKey,
    this.confirmKey,
    this.confirmEnabled = true,
    this.destructiveConfirm = false,
    this.buttonPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.sm,
    ),
    this.cancelTextStyle,
    this.confirmTextStyle,
  });

  final ColorScheme colors;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;
  final Key? cancelKey;
  final Key? confirmKey;
  final bool confirmEnabled;
  final bool destructiveConfirm;
  final EdgeInsets buttonPadding;
  final TextStyle? cancelTextStyle;
  final TextStyle? confirmTextStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
            style:
                cancelTextStyle ??
                AppTypography.button.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ElevatedButton(
          key: confirmKey,
          onPressed: confirmEnabled ? onConfirm : null,
          style: destructiveConfirm
              ? AppButtonStyles.destructiveFilled(
                  colors,
                  padding: buttonPadding,
                )
              : AppButtonStyles.primaryFilled(colors, padding: buttonPadding),
          child: Text(
            confirmLabel,
            style:
                confirmTextStyle ??
                AppTypography.button.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class SheetActionBar extends StatelessWidget {
  const SheetActionBar({
    super.key,
    required this.colors,
    required this.leadingLabel,
    required this.trailingLabel,
    required this.onLeadingPressed,
    required this.onTrailingPressed,
    this.leadingBorderWidth,
    this.spacing = AppSpacing.md,
    this.leadingTextStyle,
    this.trailingTextStyle,
  });

  final ColorScheme colors;
  final String leadingLabel;
  final String trailingLabel;
  final VoidCallback onLeadingPressed;
  final VoidCallback onTrailingPressed;
  final double? leadingBorderWidth;
  final double spacing;
  final TextStyle? leadingTextStyle;
  final TextStyle? trailingTextStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onLeadingPressed,
            style: AppButtonStyles.primaryOutline(
              colors,
              borderWidth: leadingBorderWidth ?? 1.4,
              useLighter: true,
            ),
            child: Text(
              leadingLabel,
              style:
                  leadingTextStyle ??
                  AppTypography.button.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: ElevatedButton(
            onPressed: onTrailingPressed,
            style: AppButtonStyles.primaryFilled(colors),
            child: Text(
              trailingLabel,
              style:
                  trailingTextStyle ??
                  AppTypography.button.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class ConfirmActionDialog extends StatelessWidget {
  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.content,
    required this.cancelLabel,
    required this.confirmLabel,
    this.destructiveConfirm = false,
  });

  final Widget title;
  final Widget content;
  final String cancelLabel;
  final String confirmLabel;
  final bool destructiveConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      title: title,
      content: content,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      actions: [
        DialogActionBar(
          colors: colors,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
          destructiveConfirm: destructiveConfirm,
        ),
      ],
    );
  }
}
