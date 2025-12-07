import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, required this.size});

  final double size;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnim.switcher,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final alignment =
            Alignment(-1 + 2 * _controller.value, -1 + 2 * _controller.value);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            gradient: LinearGradient(
              begin: alignment,
              end: Alignment(-alignment.x, -alignment.y),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }
}
