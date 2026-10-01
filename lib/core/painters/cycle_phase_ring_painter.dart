import 'dart:math' as math;
import 'package:flutter/material.dart';

class CyclePhaseRingPainter extends CustomPainter {
  final double periodFraction;
  final double follicularFraction;
  final double fertileFraction;
  final double lutealFraction;
  final double todayProgress;
  final double ovulationProgress;

  CyclePhaseRingPainter({
    required this.periodFraction,
    required this.follicularFraction,
    required this.fertileFraction,
    required this.lutealFraction,
    required this.todayProgress,
    required this.ovulationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;
    const strokeWidth = 16.0;
    const startAngle = -math.pi / 2;

    void drawArc(double fractionStart, double fraction, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + fractionStart * 2 * math.pi,
        fraction * 2 * math.pi * 0.96,
        false,
        paint,
      );
    }

    double cursor = 0;
    drawArc(cursor, periodFraction, const Color(0xFFED5589));
    cursor += periodFraction;
    drawArc(cursor, follicularFraction, const Color(0xFF6C5CE7));
    cursor += follicularFraction;
    drawArc(cursor, fertileFraction, const Color(0xFFF5C77E));
    cursor += fertileFraction;
    drawArc(cursor, lutealFraction, const Color(0xFFD8CFF0));

    final todayAngle = startAngle + todayProgress * 2 * math.pi;
    final todayPoint = Offset(center.dx + radius * math.cos(todayAngle), center.dy + radius * math.sin(todayAngle));
    canvas.drawCircle(todayPoint, 11, Paint()..color = Colors.white);
    canvas.drawCircle(todayPoint, 7, Paint()..color = const Color(0xFF2E2A4A));

    final ovAngle = startAngle + ovulationProgress * 2 * math.pi;
    final ovPoint = Offset(center.dx + radius * math.cos(ovAngle), center.dy + radius * math.sin(ovAngle));
    canvas.drawCircle(ovPoint, 6, Paint()..color = const Color(0xFF6C5CE7));
  }

  @override
  bool shouldRepaint(covariant CyclePhaseRingPainter oldDelegate) => true;
}
