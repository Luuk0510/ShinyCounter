import 'package:flutter/material.dart';

/// Wraps bottom-sheet content with safe-area + keyboard inset handling.
///
/// Use this instead of repeating `SafeArea + MediaQuery.viewInsets` padding.
class SafeAreaSheet extends StatelessWidget {
  const SafeAreaSheet({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.safeAreaSides = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool safeAreaSides;

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: safeAreaTop,
      bottom: safeAreaBottom,
      left: safeAreaSides,
      right: safeAreaSides,
      child: Padding(
        padding: padding,
        child: Padding(
          padding: EdgeInsets.only(bottom: viewInsetsBottom),
          child: child,
        ),
      ),
    );
  }
}
