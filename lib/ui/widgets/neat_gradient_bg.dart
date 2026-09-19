import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class NeatGradientBg extends StatefulWidget {
  final Widget child;
  final double borderRadius;

  const NeatGradientBg({
    super.key, 
    required this.child,
    this.borderRadius = 28.0,
  });

  @override
  State<NeatGradientBg> createState() => _NeatGradientBgState();
}

class _NeatGradientBgState extends State<NeatGradientBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          // Background Color - Deep Violet
          Container(color: const Color(0xFF2A004F)),
          
          // Animated gradient blobs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value * 2 * math.pi;
              return CustomPaint(
                painter: _MeshGradientPainter(t),
                size: Size.infinite,
              );
            },
          ),
          
          // Blur Layer to merge colors deeply
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
          
          // Floating particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlesPainter(_controller.value * 2 * math.pi),
                size: Size.infinite,
              );
            }
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final double time;

  _MeshGradientPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // Red / Magenta
    final paint1 = Paint()
      ..color = const Color(0xFFFF1E4E)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Orange / Yellow-ish
    final paint2 = Paint()
      ..color = const Color(0xFFFF5D29)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

    // Deep bright purple
    final paint3 = Paint()
      ..color = const Color(0xFF8B18D6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Bright intense pink/red
    final paint4 = Paint()
      ..color = const Color(0xFFFF0055)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final w = size.width;
    final h = size.height;

    // Organic fluid movement math
    canvas.drawCircle(
      Offset(w * 0.5 + math.sin(time) * w * 0.4, h * 0.5 + math.cos(time * 0.8) * h * 0.4),
      w * 0.75,
      paint1,
    );

    canvas.drawCircle(
      Offset(w * 0.3 + math.cos(time * 1.2) * w * 0.5, h * 0.8 + math.sin(time * 1.1) * h * 0.5),
      w * 0.65,
      paint2,
    );

    canvas.drawCircle(
      Offset(w * 0.8 + math.sin(time * 0.9) * w * 0.4, h * 0.3 + math.cos(time * 1.3) * h * 0.4),
      w * 0.8,
      paint3,
    );

    canvas.drawCircle(
      Offset(w * 0.5 + math.cos(time * 1.5) * w * 0.3, h * 0.5 + math.sin(time * 0.7) * h * 0.3),
      w * 0.7,
      paint4,
    );
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class _ParticlesPainter extends CustomPainter {
  final double time; // 0 to 2pi
  
  _ParticlesPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final random = math.Random(42); // deterministic seed
    final w = size.width;
    final h = size.height;

    for (int i = 0; i < 20; i++) {
      // Create deterministic random base positions and speeds
      final baseX = random.nextDouble() * w;
      final baseY = random.nextDouble() * h;
      final speedX = (random.nextDouble() - 0.5) * 40;
      final speedY = (random.nextDouble() - 0.5) * 40;
      
      // Calculate floating offset using sine waves
      // use different phases based on index
      final offsetX = math.sin(time + i) * speedX;
      final offsetY = math.cos(time + i * 0.5) * speedY;
      
      // Make particles pulse in size and opacity
      final pulse = (math.sin(time * 2 + i) + 1) / 2; // 0 to 1
      paint.color = Colors.white.withOpacity(0.2 + pulse * 0.4);
      final radius = 1.0 + pulse * 2.5;

      canvas.drawCircle(Offset(baseX + offsetX, baseY + offsetY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
