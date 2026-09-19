import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedGradientWave extends StatefulWidget {
  final Widget child;
  const AnimatedGradientWave({super.key, required this.child});

  @override
  State<AnimatedGradientWave> createState() => _AnimatedGradientWaveState();
}

class _AnimatedGradientWaveState extends State<AnimatedGradientWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
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
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.8),
                const Color(0xFF3B82F6).withOpacity(0.8),
                const Color(0xFFEC4899).withOpacity(0.8),
              ],
              stops: [
                0.0,
                0.5 + (_controller.value * 0.2),
                1.0,
              ],
              transform: GradientRotation(_controller.value * 2 * pi),
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
