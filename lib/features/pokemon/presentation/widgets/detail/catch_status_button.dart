import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class CatchStatusButton extends StatelessWidget {
  const CatchStatusButton({
    super.key,
    required this.colors,
    required this.caught,
    required this.buttonPressed,
    required this.sparkleAnimation,
    required this.onTap,
  });

  final ColorScheme colors;
  final bool caught;
  final bool buttonPressed;
  final Animation<double> sparkleAnimation;
  final VoidCallback onTap;

  static const List<_SparkleBurstSpec> _sparkleBurst = [
    _SparkleBurstSpec(
      offset: Offset(-28, -18),
      delay: 0.0,
      scale: 1.0,
      turns: AppAnim.sparkleRotationTurns,
    ),
    _SparkleBurstSpec(
      offset: Offset(30, -10),
      delay: 0.08,
      scale: 0.85,
      turns: -AppAnim.sparkleRotationTurns * 0.9,
    ),
    _SparkleBurstSpec(
      offset: Offset(-22, 22),
      delay: 0.12,
      scale: 0.75,
      turns: AppAnim.sparkleRotationTurns * 0.7,
    ),
    _SparkleBurstSpec(
      offset: Offset(18, 28),
      delay: 0.16,
      scale: 0.7,
      turns: -AppAnim.sparkleRotationTurns * 0.6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bg = caught ? Colors.green.shade600 : colors.secondary;
    final fg = caught ? Colors.black : colors.onSecondary;

    final button = AnimatedScale(
      scale: buttonPressed ? AppAnim.buttonPressScale : 1,
      duration: AppAnim.fast,
      curve: AppAnim.easeOutCubic,
      child: AnimatedContainer(
        duration: AppAnim.fast,
        curve: AppAnim.easeOut,
        width: AppSizes.primaryButtonWidth,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('detail.catchButton'),
            borderRadius: BorderRadius.circular(AppRadii.md),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: AnimatedSwitcher(
                duration: AppAnim.fast,
                child: Text(
                  caught ? l10n.buttonCaught : l10n.buttonCatch,
                  key: ValueKey(caught),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.buttonTextSize,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                transitionBuilder: (child, animation) => child,
              ),
            ),
          ),
        ),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: sparkleAnimation,
              builder: (context, child) {
                final t = sparkleAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final spec in _sparkleBurst)
                      _SparkleBurst(
                        spec: spec,
                        t: t,
                        baseSize: AppSizes.catchSparkleSize,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SparkleBurstSpec {
  const _SparkleBurstSpec({
    required this.offset,
    required this.delay,
    required this.scale,
    required this.turns,
  });

  final Offset offset;
  final double delay;
  final double scale;
  final double turns;
}

class _SparkleBurst extends StatelessWidget {
  const _SparkleBurst({
    required this.spec,
    required this.t,
    required this.baseSize,
  });

  final _SparkleBurstSpec spec;
  final double t;
  final double baseSize;

  @override
  Widget build(BuildContext context) {
    final raw = (t - spec.delay) / (1 - spec.delay);
    final clamped = raw.clamp(0.0, 1.0);
    if (clamped == 0) {
      return const SizedBox.shrink();
    }
    final eased = AppAnim.easeOutCubic.transform(clamped);
    final fadeIn = AppAnim.sparkleFadeInFraction;
    final opacity = clamped <= fadeIn
        ? clamped / fadeIn
        : (1 - (clamped - fadeIn) / (1 - fadeIn));
    final scale =
        AppAnim.sparkleStartScale +
        (AppAnim.sparkleEndScale - AppAnim.sparkleStartScale) * eased;
    final turns = -spec.turns + (spec.turns * 2) * eased;
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: spec.offset * eased,
        child: Transform.rotate(
          angle: turns * 2 * math.pi,
          child: Transform.scale(
            scale: scale * spec.scale,
            child: Image.asset(
              AppAssets.sparkle,
              width: baseSize,
              height: baseSize,
            ),
          ),
        ),
      ),
    );
  }
}
