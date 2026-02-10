import 'package:flutter/material.dart';
import 'dart:math' show pi, sin, cos;

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
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
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF6366F1), const Color(0xFF8B5CF6), _controller.value)!,
                Color.lerp(const Color(0xFF4F46E5), const Color(0xFF7C3AED), _controller.value)!,
              ],
            ),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: WavePainter(_controller.value),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final yOffset = size.height * (0.3 + i * 0.2);
      
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x += 10) {
        final y = yOffset + 
            sin((x / size.width * 2 * pi) + (animationValue * 2 * pi) + (i * pi / 3)) * 30;
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }

    // Draw floating circles
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        size.width * (0.1 + i * 0.2 + sin(animationValue * 2 * pi + i) * 0.05),
        size.height * (0.2 + cos(animationValue * 2 * pi + i * 0.5) * 0.1),
      );
      canvas.drawCircle(offset, 20 + i * 10, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}