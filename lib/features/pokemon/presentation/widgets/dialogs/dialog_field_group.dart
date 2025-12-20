import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class DialogFieldGroup extends StatelessWidget {
  const DialogFieldGroup({
    super.key,
    required this.children,
    this.spacing = AppSpacing.lg,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i != children.length - 1) {
        spaced.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: spaced,
    );
  }
}
