import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class CounterControls extends StatelessWidget {
  const CounterControls({
    super.key,
    required this.count,
    required this.enabled,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
  });

  final int count;
  final bool enabled;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onEdit,
          child: Text(
            '$count',
            style: textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundIconButton(
              icon: Icons.remove,
              onPressed: onDecrement,
              background: colors.primaryContainer,
              foreground: colors.onPrimaryContainer,
              enabled: enabled,
            ),
            const SizedBox(width: AppSpacing.xl),
            _RoundIconButton(
              icon: Icons.add,
              onPressed: onIncrement,
              background: colors.primaryContainer,
              foreground: colors.onPrimaryContainer,
              enabled: enabled,
            ),
          ],
        ),
      ],
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
    final Color effectiveBg = enabled
        ? background
        : colors.surfaceContainerHighest;
    final Color effectiveFg = enabled ? foreground : colors.onSurfaceVariant;

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBg,
        foregroundColor: effectiveFg,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(AppSizes.counterButtonPadding),
        minimumSize:
            const Size(AppSizes.counterButtonSize, AppSizes.counterButtonSize),
      ),
      child: Icon(icon, size: AppSizes.counterIconSize),
    );
  }
}
