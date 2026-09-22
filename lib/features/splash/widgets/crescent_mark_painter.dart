import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrescentMarkPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentPinkColor;
  final double whiteProgress;

  CrescentMarkPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentPinkColor,
    required this.whiteProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Color blendedPink = Color.lerp(accentPinkColor, Colors.white, whiteProgress)!;
    final Color blendedPrimary = Color.lerp(primaryColor, Colors.white, whiteProgress)!;
    final Color blendedSecondary = Color.lerp(secondaryColor, Colors.white, whiteProgress)!;

    paint.shader = SweepGradient(
      center: Alignment.center,
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [
        blendedSecondary,
        blendedSecondary,
        blendedPrimary,
        blendedPink,
        blendedSecondary,
        blendedSecondary,
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 0.9, 1.0],
    ).createShader(rect);

    final Path outerCircle = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    final double innerMargin = size.width * 0.13;
    final Path innerCutout = Path()
      ..addOval(Rect.fromLTWH(
        innerMargin * 2,
        innerMargin,
        size.width - (innerMargin * 2),
        size.height - (innerMargin * 2),
      ));

    final Path crescentPath = Path.combine(
      PathOperation.difference,
      outerCircle,
      innerCutout,
    );

    canvas.drawPath(crescentPath, paint);
  }

  @override
  bool shouldRepaint(covariant CrescentMarkPainter oldDelegate) {
    return oldDelegate.whiteProgress != whiteProgress;
  }
}