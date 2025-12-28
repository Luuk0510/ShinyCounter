import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
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
    final seedColor = context.watch<ThemeNotifier>().seedColor;
    final onSeed = AppButtonPalette.onSeed(seedColor);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onEdit,
          child: TweenAnimationBuilder<double>(
            key: ValueKey(count),
            tween: Tween<double>(begin: 1.1, end: 1),
            duration: AppAnim.fast,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Text(
              '$count',
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundIconButton(
              icon: Icons.remove,
              onPressed: onDecrement,
              background: seedColor,
              foreground: onSeed,
              enabled: enabled,
            ),
            const SizedBox(width: AppSpacing.xl),
            _RoundIconButton(
              icon: Icons.add,
              onPressed: onIncrement,
              background: seedColor,
              foreground: onSeed,
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
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(AppSizes.counterButtonPadding),
        minimumSize: const Size(
          AppSizes.counterButtonSize,
          AppSizes.counterButtonSize,
        ),
      ),
      child: Icon(icon, size: AppSizes.counterIconSize),
    );
  }
}
