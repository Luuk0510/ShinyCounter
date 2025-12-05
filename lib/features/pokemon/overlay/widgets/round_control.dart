import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class RoundControl extends StatelessWidget {
  const RoundControl({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.overlayControlGap,
      ),
      child: Material(
        color: Colors.white.withValues(alpha: 0.0),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.overlayControlPad),
            child: Icon(
              icon,
              color: Colors.white,
              size: AppSizes.overlayControlSize,
            ),
          ),
        ),
      ),
    );
  }
}
