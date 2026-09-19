import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class AnimatedBlurBackground extends StatefulWidget {
  const AnimatedBlurBackground({super.key});

  @override
  State<AnimatedBlurBackground> createState() => _AnimatedBlurBackgroundState();
}

class _AnimatedBlurBackgroundState extends State<AnimatedBlurBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep purple base
        Container(color: const Color(0xFF2A004F)),
        
        // Fluid Lava Mesh
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value * 2 * math.pi;
            return CustomPaint(
              painter: _AppMeshGradientPainter(t),
              size: Size.infinite,
            );
          },
        ),
        
        // Deep blur layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(color: Colors.transparent),
          ),
        ),

        // Fade to dark at the bottom so content is readable
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF0F0C16).withOpacity(0.6),
                  const Color(0xFF050308),
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppMeshGradientPainter extends CustomPainter {
  final double time;

  _AppMeshGradientPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // Red / Magenta
    final paint1 = Paint()
      ..color = const Color(0xFFFF1E4E)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Orange / Yellow-ish
    final paint2 = Paint()
      ..color = const Color(0xFFFF5D29)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Deep bright purple
    final paint3 = Paint()
      ..color = const Color(0xFF8B18D6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final w = size.width;
    final h = size.height;

    // Organic fluid movement math for the app background
    canvas.drawCircle(
      Offset(w * 0.4 + math.sin(time) * w * 0.4, h * 0.3 + math.cos(time * 0.8) * h * 0.3),
      w * 0.8,
      paint1,
    );

    canvas.drawCircle(
      Offset(w * 0.7 + math.cos(time * 1.2) * w * 0.3, h * 0.6 + math.sin(time * 1.1) * h * 0.4),
      w * 0.7,
      paint2,
    );

    canvas.drawCircle(
      Offset(w * 0.3 + math.sin(time * 0.9) * w * 0.5, h * 0.2 + math.cos(time * 1.3) * h * 0.4),
      w * 0.9,
      paint3,
    );
  }

  @override
  bool shouldRepaint(covariant _AppMeshGradientPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
