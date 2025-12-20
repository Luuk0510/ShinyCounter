import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class SelectableRow extends StatelessWidget {
  const SelectableRow({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    required this.selectedColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.md)),
    this.selectedOpacity = 0.08,
    this.height,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final Color selectedColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double selectedOpacity;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withValues(alpha: selectedOpacity)
                : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}

class SelectableCheckmark extends StatelessWidget {
  const SelectableCheckmark({
    super.key,
    required this.selected,
    required this.selectedColor,
    this.unselectedColor,
    this.selectedIcon = Icons.check_circle,
    this.unselectedIcon,
    this.iconSize,
    this.animate = false,
    this.width,
    this.duration = AppAnim.fast,
    this.curve = AppAnim.easeOutCubic,
  });

  final bool selected;
  final Color selectedColor;
  final Color? unselectedColor;
  final IconData selectedIcon;
  final IconData? unselectedIcon;
  final double? iconSize;
  final bool animate;
  final double? width;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? selectedIcon : unselectedIcon;
    final size = iconSize ?? IconTheme.of(context).size ?? 24;
    final color = selected ? selectedColor : (unselectedColor ?? selectedColor);

    if (!animate) {
      if (icon == null) return const SizedBox.shrink();
      return Icon(icon, color: color, size: size);
    }

    final show = icon != null;
    final targetWidth = show ? (width ?? size) : 0.0;
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: Alignment.centerRight,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: targetWidth,
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            duration: duration,
            curve: curve,
            opacity: show ? 1 : 0,
            child: Icon(icon ?? selectedIcon, color: color, size: size),
          ),
        ),
      ),
    );
  }
}
