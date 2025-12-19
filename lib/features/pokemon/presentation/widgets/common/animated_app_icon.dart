import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/app_image.dart';

class AnimatedAppIcon extends StatefulWidget {
  const AnimatedAppIcon({super.key, required this.assetPath, this.size = 28});

  static const tapTargetKey = Key('animatedAppIcon.tapTarget');
  static const transformKey = Key('animatedAppIcon.transform');

  final String assetPath;
  final double size;

  @override
  State<AnimatedAppIcon> createState() => _AnimatedAppIconState();
}

class _AnimatedAppIconState extends State<AnimatedAppIcon>
    with SingleTickerProviderStateMixin {
  bool _alive = true;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppAnim.normal,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.0,
        end: 0.92,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0.92,
        end: 1.08,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.08,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 25,
    ),
  ]).animate(_controller);

  late final Animation<double> _angle = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0.0,
        end: -0.14,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: -0.14,
        end: 0.14,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0.14,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 25,
    ),
  ]).animate(_controller);

  void _play() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
    _playHapticPattern();
  }

  void _playHapticPattern() {
    final duration = _controller.duration ?? AppAnim.normal;
    final ms = duration.inMilliseconds;

    _safeHaptic(HapticFeedback.lightImpact);
    Future.delayed(Duration(milliseconds: (ms * 0.35).round()), () {
      if (!_alive) return;
      _safeHaptic(HapticFeedback.selectionClick);
    });
    Future.delayed(Duration(milliseconds: (ms * 0.70).round()), () {
      if (!_alive) return;
      _safeHaptic(HapticFeedback.selectionClick);
    });
  }

  void _safeHaptic(Future<void> Function() call) {
    try {
      call();
    } catch (_) {}
  }

  @override
  void dispose() {
    _alive = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _play,
      key: AnimatedAppIcon.tapTargetKey,
      child: AnimatedBuilder(
        animation: _controller,
        child: AppImage(
          image: AssetImage(widget.assetPath),
          width: widget.size,
          height: widget.size,
          borderRadius: 0,
          fallbackIcon: Icons.catching_pokemon,
          fallbackIconSize: 24,
        ),
        builder: (context, child) {
          return Transform.rotate(
            key: AnimatedAppIcon.transformKey,
            angle: _angle.value,
            child: Transform.scale(scale: _scale.value, child: child),
          );
        },
      ),
    );
  }
}
