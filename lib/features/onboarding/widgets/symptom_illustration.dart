import 'package:flutter/material.dart';

/// Ilustrasi flat untuk pilihan gejala.
/// id: cramps, fatigue, bloating, tender_breasts, backache, none
class SymptomIllustration extends StatelessWidget {
  final String id;
  final double size;

  const SymptomIllustration({Key? key, required this.id, this.size = 74})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SymptomPainter(id)),
    );
  }
}

class _SymptomPainter extends CustomPainter {
  final String id;
  _SymptomPainter(this.id);

  Paint _p(Color c, {PaintingStyle style = PaintingStyle.fill, double w = 0}) =>
      Paint()
        ..color = c
        ..style = style
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

  RRect _rr(double l, double t, double r, double b, double rad) =>
      RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

  Path _bolt(double x, double y, double s) {
    return Path()
      ..moveTo(x + 2 * s, y)
      ..lineTo(x - 2 * s, y + 5 * s)
      ..lineTo(x + 0.5 * s, y + 5 * s)
      ..lineTo(x - 1 * s, y + 10 * s)
      ..lineTo(x + 3.5 * s, y + 3.5 * s)
      ..lineTo(x + 1 * s, y + 3.5 * s)
      ..close();
  }

  Path _heart(Offset c, double s) {
    return Path()
      ..moveTo(c.dx, c.dy + s * 0.9)
      ..cubicTo(c.dx - s * 1.4, c.dy - s * 0.1, c.dx - s * 0.8, c.dy - s * 1.1,
          c.dx, c.dy - s * 0.4)
      ..cubicTo(c.dx + s * 0.8, c.dy - s * 1.1, c.dx + s * 1.4, c.dy - s * 0.1,
          c.dx, c.dy + s * 0.9)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 50)));

    switch (id) {
      case 'cramps':
        _cramps(canvas);
        break;
      case 'fatigue':
        _fatigue(canvas);
        break;
      case 'bloating':
        _bloating(canvas);
        break;
      case 'tender_breasts':
        _tender(canvas);
        break;
      case 'backache':
        _backache(canvas);
        break;
      default:
        _none(canvas);
    }
  }

  void _bg(Canvas canvas, Color c) =>
      canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(c));

  void _cramps(Canvas canvas) {
    _bg(canvas, const Color(0xFFF9D3DC));

    // tuba & ovarium
    final tube = _p(const Color(0xFFE8668A), style: PaintingStyle.stroke, w: 3.5);
    canvas.drawPath(
        Path()
          ..moveTo(38, 40)
          ..quadraticBezierTo(28, 28, 18, 36),
        tube);
    canvas.drawPath(
        Path()
          ..moveTo(62, 40)
          ..quadraticBezierTo(72, 28, 82, 36),
        tube);
    canvas.drawCircle(const Offset(17, 39), 5, _p(const Color(0xFFF5A3B8)));
    canvas.drawCircle(const Offset(83, 39), 5, _p(const Color(0xFFF5A3B8)));

    // rahim
    final uterus = Path()
      ..moveTo(33, 42)
      ..cubicTo(33, 26, 67, 26, 67, 42)
      ..cubicTo(67, 54, 59, 60, 55, 76)
      ..lineTo(45, 76)
      ..cubicTo(41, 60, 33, 54, 33, 42)
      ..close();
    canvas.drawPath(uterus, _p(const Color(0xFFE8446D)));
    canvas.drawOval(const Rect.fromLTWH(40, 34, 20, 12), _p(const Color(0xFFF58BA5)));

    // petir nyeri
    canvas.drawPath(_bolt(74, 54, 1.8), _p(const Color(0xFFFFC928)));
    canvas.drawPath(_bolt(18, 56, 1.8), _p(const Color(0xFFFFC928)));
  }

  void _fatigue(Canvas canvas) {
    _bg(canvas, const Color(0xFFE3DAF5));

    canvas.drawRRect(_rr(44, 18, 56, 25, 3), _p(const Color(0xFF4A4A57)));
    canvas.drawRRect(_rr(32, 23, 68, 80, 10), _p(const Color(0xFFC9BBEE)));
    // sisa daya sedikit
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(32, 68, 68, 80,
          bottomLeft: const Radius.circular(10), bottomRight: const Radius.circular(10)),
      _p(const Color(0xFFF0707F)),
    );

    // mata mengantuk
    final eye = _p(const Color(0xFF3B2F5C), style: PaintingStyle.stroke, w: 2.4);
    canvas.drawArc(const Rect.fromLTWH(38, 40, 10, 8), 0.1, 2.9, false, eye);
    canvas.drawArc(const Rect.fromLTWH(52, 40, 10, 8), 0.1, 2.9, false, eye);
    canvas.drawArc(const Rect.fromLTWH(44, 56, 12, 7), 3.3, 2.6, false, eye);

    // zZ
    final z = _p(const Color(0xFF8E7CC3), style: PaintingStyle.stroke, w: 2.4);
    canvas.drawPath(
        Path()
          ..moveTo(74, 22)
          ..lineTo(82, 22)
          ..lineTo(74, 31)
          ..lineTo(82, 31),
        z);
    canvas.drawPath(
        Path()
          ..moveTo(84, 12)
          ..lineTo(89, 12)
          ..lineTo(84, 18)
          ..lineTo(89, 18),
        z);
  }

  void _bloating(Canvas canvas) {
    _bg(canvas, const Color(0xFFD9ECFA));

    // tali
    canvas.drawPath(
        Path()
          ..moveTo(50, 70)
          ..quadraticBezierTo(44, 80, 52, 90),
        _p(const Color(0xFF8E7CC3), style: PaintingStyle.stroke, w: 2));
    // simpul
    canvas.drawPath(
        Path()
          ..moveTo(50, 68)
          ..lineTo(45, 75)
          ..lineTo(55, 75)
          ..close(),
        _p(const Color(0xFF9B59B6)));
    // balon
    canvas.drawOval(const Rect.fromLTWH(26, 14, 48, 56), _p(const Color(0xFFB66BD6)));
    canvas.drawOval(const Rect.fromLTWH(26, 14, 48, 56),
        _p(const Color(0xFF9B4FC2), style: PaintingStyle.stroke, w: 2));
    // kilau
    canvas.drawArc(const Rect.fromLTWH(33, 22, 16, 22), 3.5, 1.3, false,
        _p(Colors.white.withValues(alpha: 0.75), style: PaintingStyle.stroke, w: 3));
    // gelembung kecil
    canvas.drawCircle(const Offset(80, 30), 4, _p(const Color(0xFFFFFFFF).withValues(alpha: 0.9)));
    canvas.drawCircle(const Offset(86, 44), 2.5, _p(const Color(0xFFFFFFFF).withValues(alpha: 0.9)));
  }

  void _tender(Canvas canvas) {
    _bg(canvas, const Color(0xFFFBD6D2));

    // aura
    canvas.drawCircle(const Offset(50, 50), 34, _p(Colors.white.withValues(alpha: 0.35)));
    // hati
    canvas.drawPath(_heart(const Offset(50, 50), 26), _p(const Color(0xFFE8446D)));
    canvas.drawArc(const Rect.fromLTWH(28, 34, 14, 14), 3.5, 1.4, false,
        _p(Colors.white.withValues(alpha: 0.7), style: PaintingStyle.stroke, w: 3));
    // plester
    canvas.save();
    canvas.translate(50, 52);
    canvas.rotate(-0.7);
    canvas.drawRRect(_rr(-20, -6, 20, 6, 6), _p(const Color(0xFFF6D9B0)));
    canvas.drawRRect(_rr(-7, -6, 7, 6, 1), _p(const Color(0xFFEBC48F)));
    canvas.restore();
    // kilau
    canvas.drawCircle(const Offset(80, 24), 3, _p(Colors.white));
    canvas.drawCircle(const Offset(20, 74), 2.5, _p(Colors.white));
  }

  void _backache(Canvas canvas) {
    _bg(canvas, const Color(0xFFE6DDF7));

    // badan (tampak belakang)
    canvas.drawRRect(_rr(30, 40, 70, 90, 16), _p(const Color(0xFF7E6BC0)));
    // lengan
    canvas.drawRRect(_rr(22, 44, 34, 74, 6), _p(const Color(0xFF6F5CB3)));
    canvas.drawRRect(_rr(66, 44, 78, 74, 6), _p(const Color(0xFF6F5CB3)));
    // leher & kepala
    canvas.drawRRect(_rr(44, 32, 56, 42, 3), _p(const Color(0xFFEBB08A)));
    canvas.drawCircle(const Offset(50, 24), 12, _p(const Color(0xFF4A3B6B)));
    canvas.drawCircle(const Offset(50, 26), 10, _p(const Color(0xFFF2C09E)));
    canvas.drawArc(const Rect.fromLTWH(38, 10, 24, 20), 3.14, 3.14, true,
        _p(const Color(0xFF4A3B6B)));
    // tulang belakang
    canvas.drawLine(const Offset(50, 44), const Offset(50, 80),
        _p(Colors.white.withValues(alpha: 0.35), style: PaintingStyle.stroke, w: 2));
    // titik nyeri
    canvas.drawCircle(const Offset(50, 66), 14, _p(const Color(0xFFFF5A7A).withValues(alpha: 0.25)));
    canvas.drawCircle(const Offset(50, 66), 9, _p(const Color(0xFFFF5A7A).withValues(alpha: 0.5)));
    canvas.drawCircle(const Offset(50, 66), 4.5, _p(const Color(0xFFE8446D)));
  }

  void _none(Canvas canvas) {
    _bg(canvas, const Color(0xFFE4EDE6));

    canvas.drawCircle(const Offset(50, 50), 28, _p(const Color(0xFFB9D8BF)));
    canvas.drawCircle(const Offset(50, 50), 22, _p(const Color(0xFF7DBB8A)));
    canvas.drawPath(
        Path()
          ..moveTo(39, 51)
          ..lineTo(47, 59)
          ..lineTo(62, 42),
        _p(Colors.white, style: PaintingStyle.stroke, w: 5));
    // kilau
    canvas.drawCircle(const Offset(18, 26), 3, _p(Colors.white));
    canvas.drawCircle(const Offset(82, 76), 3.5, _p(Colors.white));
    canvas.drawCircle(const Offset(80, 24), 2, _p(Colors.white));
  }

  @override
  bool shouldRepaint(covariant _SymptomPainter oldDelegate) => oldDelegate.id != id;
}