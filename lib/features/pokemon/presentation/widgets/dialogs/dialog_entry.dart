import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

/// Small reusable entry animation for dialogs/sheets to avoid per-dialog
/// animation code and keep motion consistent.
class DialogEntry extends StatelessWidget {
  const DialogEntry({
    super.key,
    required this.child,
    this.duration = AppAnim.dialogDuration,
    this.curve = AppAnim.dialogCurve,
    this.startScale = AppAnim.dialogStartScale,
    this.reverse = false,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double startScale;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final begin = reverse ? 1.0 : startScale;
    final end = reverse ? startScale : 1.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, _) {
        final opacity = ((value - startScale) / (1 - startScale)).clamp(
          0.0,
          1.0,
        );
        return AnimatedOpacity(
          duration: duration,
          opacity: opacity,
          curve: curve,
          child: Transform.scale(scale: value, child: child),
        );
      },
    );
  }
}
