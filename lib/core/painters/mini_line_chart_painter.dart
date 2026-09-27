import 'package:flutter/material.dart';

class ChartSeries {
  final List<double> values;
  final Color color;
  final String label;
  const ChartSeries({required this.values, required this.color, required this.label});
}

class MiniLineChartPainter extends CustomPainter {
  final List<ChartSeries> series;
  final double maxY;

  MiniLineChartPainter({required this.series, required this.maxY});

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFEDEAF5)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final s in series) {
      if (s.values.length < 2) continue;
      final path = Path();
      final stepX = size.width / (s.values.length - 1);
      for (int i = 0; i < s.values.length; i++) {
        final x = stepX * i;
        final y = size.height - (s.values[i] / maxY) * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevX = stepX * (i - 1);
          final prevY = size.height - (s.values[i - 1] / maxY) * size.height;
          final midX = (prevX + x) / 2;
          final midY = (prevY + y) / 2;
          path.quadraticBezierTo(prevX, prevY, midX, midY);
          path.quadraticBezierTo(midX, midY, x, y);
        }
      }
      final linePaint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MiniLineChartPainter oldDelegate) => true;
}