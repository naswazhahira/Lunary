import 'dart:math' as math;
import 'package:flutter/material.dart';

class CycleRingPainter extends CustomPainter {
  final double shrinkFactor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentPinkColor;
  final Color darkTextColor;

  CycleRingPainter({
    required this.shrinkFactor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentPinkColor,
    required this.darkTextColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double dotRadius = 7.0 * shrinkFactor;
    final double orbitRadius = (radius - 15) * shrinkFactor;

    final List<Color> dotColors = [
      secondaryColor.withOpacity(0.6),
      secondaryColor,
      secondaryColor,
      primaryColor,
      primaryColor.withOpacity(0.8),
      accentPinkColor,
      accentPinkColor.withOpacity(0.7),
      secondaryColor,
    ];

    for (int i = 0; i < 8; i++) {
      double angle = (i * 45 - 90) * (math.pi / 180);
      double x = center.dx + orbitRadius * math.cos(angle);
      double y = center.dy + orbitRadius * math.sin(angle);

      final Paint paint = Paint()
        ..color = dotColors[i]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }

    final Paint centerDotPaint = Paint()
      ..color = darkTextColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, (dotRadius + 4) * shrinkFactor, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CycleRingPainter oldDelegate) => true;
}