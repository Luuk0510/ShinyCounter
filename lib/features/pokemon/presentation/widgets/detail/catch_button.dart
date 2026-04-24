import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class CatchButton extends StatefulWidget {
  const CatchButton({super.key, required this.caught, required this.onTap});

  final bool caught;
  final Future<void> Function() onTap;

  @override
  State<CatchButton> createState() => _CatchButtonState();
}

class _CatchButtonState extends State<CatchButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sparkleController;
  bool _buttonPressed = false;

  static const List<SparkleBurstSpec> _sparkleBurst = [
    SparkleBurstSpec(
      offset: Offset(-28, -18),
      delay: 0.0,
      scale: 1.0,
      turns: AppAnim.sparkleRotationTurns,
    ),
    SparkleBurstSpec(
      offset: Offset(30, -10),
      delay: 0.08,
      scale: 0.85,
      turns: -AppAnim.sparkleRotationTurns * 0.9,
    ),
    SparkleBurstSpec(
      offset: Offset(-22, 22),
      delay: 0.12,
      scale: 0.75,
      turns: AppAnim.sparkleRotationTurns * 0.7,
    ),
    SparkleBurstSpec(
      offset: Offset(18, 28),
      delay: 0.16,
      scale: 0.7,
      turns: -AppAnim.sparkleRotationTurns * 0.6,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: AppAnim.sparkleDuration,
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    final wasCaught = widget.caught;
    setState(() => _buttonPressed = true);
    await Future.delayed(AppAnim.faster);
    if (mounted) setState(() => _buttonPressed = false);
    if (!wasCaught) {
      _sparkleController.forward(from: 0);
    }
    await widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = widget.caught ? Colors.green.shade600 : colors.secondary;
    final fg = widget.caught ? Colors.black : colors.onSecondary;
    final l10n = context.l10n;

    final button = AnimatedScale(
      scale: _buttonPressed ? AppAnim.buttonPressScale : 1,
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
            onTap: _handleTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: AnimatedSwitcher(
                duration: AppAnim.fast,
                transitionBuilder: (child, animation) => child,
                child: Text(
                  widget.caught ? l10n.buttonCaught : l10n.buttonCatch,
                  key: ValueKey(widget.caught),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.buttonTextSize,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
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
              animation: _sparkleController,
              builder: (context, child) {
                final t = _sparkleController.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final spec in _sparkleBurst)
                      SparkleBurst(
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

class SparkleBurstSpec {
  const SparkleBurstSpec({
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

class SparkleBurst extends StatelessWidget {
  const SparkleBurst({
    super.key,
    required this.spec,
    required this.t,
    required this.baseSize,
  });

  final SparkleBurstSpec spec;
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
