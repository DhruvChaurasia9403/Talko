import 'package:flutter/material.dart';
import 'dart:math' as math;

class TypingIndicator extends StatefulWidget {
  final Color color;
  final double dotSize;

  const TypingIndicator({
    super.key,
    required this.color,
    this.dotSize = 6.0,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1000ms duration for a snappy, modern typing feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Creates a staggered wave effect using sine
            double offset = math.sin((_controller.value * 2 * math.pi) - (index * 1.2));

            // Only bounce up (negative Y axis)
            double jump = offset > 0 ? offset * 4.5 : 0;

            // Pulse the opacity as it jumps
            double opacity = 0.4 + (jump / 9).clamp(0.0, 0.6);

            return Transform.translate(
              offset: Offset(0, -jump),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}