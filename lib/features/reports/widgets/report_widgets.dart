import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

const List<String> _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String shortDate(DateTime d) => '${d.day} ${_monthNames[d.month - 1]}';
String fullDate(DateTime d) => '${shortDate(d)} ${d.year}';

/// 28.0 -> "28", 28.5 -> "28.5"
String formatNumber(double v, {int decimals = 1}) {
  var s = v.toStringAsFixed(decimals);
  if (decimals > 0 && s.contains('.')) {
    while (s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  return s;
}

int _daysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
      double fontSize = 10,
      Color color = const Color(0xFF9CA3AF),
      FontWeight weight = FontWeight.w500,
    }) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, color: color, fontWeight: weight)),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
}

// -----------------------------------------------------------------------------
// Layout
// -----------------------------------------------------------------------------

class ReportScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const ReportScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.darkText, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const ReportCard({Key? key, required this.title, this.subtitle, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final String label;
  final String value;

  const StatChip({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        ],
      ),
    );
  }
}

class ReportEmpty extends StatelessWidget {
  final IconData icon;
  final String message;

  const ReportEmpty({Key? key, required this.icon, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Grafik batang
// -----------------------------------------------------------------------------

class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color highlightColor;
  final double height;
  final int decimals;
  final bool showLabels;
  final bool highlightLast;

  const SimpleBarChart({
    Key? key,
    required this.values,
    this.labels = const [],
    this.color = const Color(0xFFB197FC),
    this.highlightColor = const Color(0xFFFFB74D),
    this.height = 180,
    this.decimals = 0,
    this.showLabels = true,
    this.highlightLast = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(
          values: values,
          labels: labels,
          color: color,
          highlightColor: highlightColor,
          decimals: decimals,
          showLabels: showLabels,
          highlightLast: highlightLast,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color highlightColor;
  final int decimals;
  final bool showLabels;
  final bool highlightLast;

  _BarPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.highlightColor,
    required this.decimals,
    required this.showLabels,
    required this.highlightLast,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final topPad = showLabels ? 18.0 : 4.0;
    final bottomPad = showLabels ? 22.0 : 2.0;
    final chartH = size.height - topPad - bottomPad;

    double maxV = values.first;
    for (final v in values) {
      maxV = math.max(maxV, v);
    }
    final double scaleMax = maxV <= 0 ? 1.0 : maxV * 1.1;

    if (showLabels) {
      final grid = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..strokeWidth = 1;
      for (int i = 0; i <= 3; i++) {
        final y = topPad + chartH * i / 3;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      }
    }

    final slot = size.width / values.length;
    final barW = (slot * 0.6).clamp(4.0, 34.0);
    final showValues = showLabels && values.length <= 12;
    final step = math.max(1, (values.length / 6).ceil());

    for (int i = 0; i < values.length; i++) {
      final h = chartH * (values[i] / scaleMax);
      final cx = slot * i + slot / 2;
      final isHi = highlightLast && i == values.length - 1;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - barW / 2, topPad + chartH - h, barW, h),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(rrect, Paint()..color = isHi ? highlightColor : color);

      if (showValues && values[i] > 0) {
        _drawText(canvas, values[i].toStringAsFixed(decimals), Offset(cx, topPad + chartH - h - 8),
            fontSize: 10, color: const Color(0xFF4B5563));
      }

      if (showLabels && i < labels.length && (values.length - 1 - i) % step == 0) {
        _drawText(canvas, labels[i], Offset(cx, size.height - 8), fontSize: 9.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// Grafik garis
// -----------------------------------------------------------------------------

class LinePoint {
  final DateTime date;
  final double value;
  const LinePoint(this.date, this.value);
}

class SimpleLineChart extends StatelessWidget {
  final List<LinePoint> points;
  final Color color;
  final double height;
  final int decimals;
  final List<DateTime> markers;
  final Color markerColor;

  const SimpleLineChart({
    Key? key,
    required this.points,
    this.color = const Color(0xFF7C3AED),
    this.height = 220,
    this.decimals = 1,
    this.markers = const [],
    this.markerColor = const Color(0xFF26A69A),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LinePainter(
          points: points,
          color: color,
          decimals: decimals,
          markers: markers,
          markerColor: markerColor,
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<LinePoint> points;
  final Color color;
  final int decimals;
  final List<DateTime> markers;
  final Color markerColor;

  _LinePainter({
    required this.points,
    required this.color,
    required this.decimals,
    required this.markers,
    required this.markerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPad = 40.0;
    const rightPad = 12.0;
    const topPad = 12.0;
    const bottomPad = 24.0;
    final w = size.width - leftPad - rightPad;
    final h = size.height - topPad - bottomPad;

    double minV = points.first.value;
    double maxV = points.first.value;
    for (final p in points) {
      minV = math.min(minV, p.value);
      maxV = math.max(maxV, p.value);
    }
    if (maxV - minV < 0.01) {
      minV -= 1;
      maxV += 1;
    } else {
      final pad = (maxV - minV) * 0.2;
      minV -= pad;
      maxV += pad;
    }

    final first = points.first.date;
    final last = points.last.date;
    final spanDays = math.max(1, _daysBetween(first, last));

    double xFor(DateTime d) {
      if (points.length == 1) return leftPad + w / 2;
      return leftPad + w * (_daysBetween(first, d) / spanDays);
    }

    double yFor(double v) => topPad + h * (1 - (v - minV) / (maxV - minV));

    // Grid + label sumbu Y
    final grid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = topPad + h * i / 3;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y), grid);
      final value = maxV - (maxV - minV) * i / 3;
      _drawText(canvas, value.toStringAsFixed(decimals), Offset(leftPad / 2 - 2, y), fontSize: 9.5);
    }

    // Penanda (ovulasi prediksi): garis putus-putus vertikal
    final markerPaint = Paint()
      ..color = markerColor
      ..strokeWidth = 1.5;
    for (final m in markers) {
      if (m.isBefore(first) || m.isAfter(last)) continue;
      final x = xFor(m);
      double y = topPad;
      while (y < topPad + h) {
        canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 4, topPad + h)), markerPaint);
        y += 8;
      }
    }

    // Garis
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final o = Offset(xFor(points[i].date), yFor(points[i].value));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Titik
    for (int i = 0; i < points.length; i++) {
      final o = Offset(xFor(points[i].date), yFor(points[i].value));
      if (i == points.length - 1) {
        canvas.drawCircle(o, 5.5, Paint()..color = color);
      } else {
        canvas.drawCircle(o, 4.5, Paint()..color = Colors.white);
        canvas.drawCircle(
          o,
          4.5,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // Label sumbu X
    final labelY = size.height - 8;
    _drawText(canvas, shortDate(first), Offset(math.max(xFor(first), leftPad + 16), labelY), fontSize: 9.5);
    if (points.length > 1) {
      _drawText(canvas, shortDate(last), Offset(math.min(xFor(last), size.width - 20), labelY),
          fontSize: 9.5);
      if (spanDays >= 6) {
        final mid = first.add(Duration(days: spanDays ~/ 2));
        _drawText(canvas, shortDate(mid), Offset(xFor(mid), labelY), fontSize: 9.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => true;
}