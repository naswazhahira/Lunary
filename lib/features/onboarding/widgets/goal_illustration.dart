import 'package:flutter/material.dart';

/// Ilustrasi flat untuk kartu tujuan di onboarding.
/// id: get_pregnant, already_pregnant, track_period, wellbeing,
///     weight, sex_life, discharge, contraception
class GoalIllustration extends StatelessWidget {
  final String id;
  final double size;

  const GoalIllustration({Key? key, required this.id, this.size = 74})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoalPainter(id)),
    );
  }
}

class _GoalPainter extends CustomPainter {
  final String id;
  _GoalPainter(this.id);

  Paint _p(Color c, {PaintingStyle style = PaintingStyle.fill, double w = 0}) =>
      Paint()
        ..color = c
        ..style = style
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

  RRect _rr(double l, double t, double r, double b, double rad) =>
      RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

  Path _heart(Offset c, double s) {
    return Path()
      ..moveTo(c.dx, c.dy + s * 0.9)
      ..cubicTo(c.dx - s * 1.4, c.dy - s * 0.1, c.dx - s * 0.8, c.dy - s * 1.1,
          c.dx, c.dy - s * 0.4)
      ..cubicTo(c.dx + s * 0.8, c.dy - s * 1.1, c.dx + s * 1.4, c.dy - s * 0.1,
          c.dx, c.dy + s * 0.9)
      ..close();
  }

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

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    const center = Offset(50, 50);
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: 50)));

    switch (id) {
      case 'get_pregnant':
        _pregnancyTest(canvas);
        break;
      case 'already_pregnant':
        _baby(canvas);
        break;
      case 'track_period':
        _calendar(canvas);
        break;
      case 'wellbeing':
        _battery(canvas);
        break;
      case 'weight':
        _scale(canvas);
        break;
      case 'sex_life':
        _hearts(canvas);
        break;
      case 'discharge':
        _underwear(canvas);
        break;
      case 'contraception':
        _contraception(canvas);
        break;
    }
  }

  void _pregnancyTest(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(const Color(0xFFE6D6F0)));
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate(-0.55);
    canvas.translate(-50, -50);
    // bayangan
    canvas.drawRRect(_rr(16, 47, 72, 61, 7), _p(Colors.black.withValues(alpha: 0.07)));
    // badan
    canvas.drawRRect(_rr(14, 43, 70, 57, 7), _p(Colors.white));
    // kepala
    canvas.drawRRect(_rr(64, 41, 88, 59, 9), _p(const Color(0xFFE8446D)));
    canvas.drawRRect(_rr(68, 45, 84, 55, 5), _p(const Color(0xFFF58BA5)));
    // jendela hasil
    canvas.drawRRect(_rr(28, 46, 46, 54, 3), _p(const Color(0xFFF9D5DE)));
    canvas.drawRect(const Rect.fromLTWH(33, 46, 2.5, 8), _p(const Color(0xFFE8446D)));
    canvas.drawRect(const Rect.fromLTWH(39, 46, 2.5, 8), _p(const Color(0xFFE8446D)));
    canvas.restore();
  }

  void _baby(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(const Color(0xFFF7C9D3)));
    // cincin rahim
    canvas.drawCircle(const Offset(50, 50), 38, _p(const Color(0xFFFBEBE4)));
    canvas.drawCircle(const Offset(50, 50), 39, _p(const Color(0xFFE8668A), style: PaintingStyle.stroke, w: 4));
    // badan
    canvas.drawOval(const Rect.fromLTWH(40, 50, 26, 28), _p(const Color(0xFFF2C09E)));
    // kaki
    canvas.drawCircle(const Offset(48, 79), 6, _p(const Color(0xFFEBB08A)));
    // kepala
    canvas.drawCircle(const Offset(48, 42), 14, _p(const Color(0xFFF5CBAA)));
    // mata tertutup & pipi
    final eye = _p(const Color(0xFF8A5A44), style: PaintingStyle.stroke, w: 1.6);
    canvas.drawArc(const Rect.fromLTWH(41, 41, 6, 4), 0.2, 2.7, false, eye);
    canvas.drawCircle(const Offset(55, 47), 2.6, _p(const Color(0xFFF2A0A0).withValues(alpha: 0.7)));
    // tangan
    canvas.drawCircle(const Offset(40, 58), 4.5, _p(const Color(0xFFEBB08A)));
    // tali pusat
    final cord = Path()
      ..moveTo(62, 62)
      ..quadraticBezierTo(76, 64, 72, 82);
    canvas.drawPath(cord, _p(const Color(0xFFE8668A), style: PaintingStyle.stroke, w: 3));
  }

  void _calendar(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(const Color(0xFFCFE4F7)));
    canvas.drawRRect(_rr(18, 26, 82, 76, 8), _p(Colors.black.withValues(alpha: 0.06)));
    canvas.drawRRect(_rr(18, 24, 82, 74, 8), _p(Colors.white));
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(18, 24, 82, 38,
          topLeft: const Radius.circular(8), topRight: const Radius.circular(8)),
      _p(const Color(0xFF8DBBE8)),
    );
    // titik tanggal
    final dot = _p(const Color(0xFFD5DEE8));
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 6; c++) {
        if (r == 1) continue;
        canvas.drawCircle(Offset(25 + c * 10.0, 45 + r * 12.0), 1.8, dot);
      }
    }
    // baris haid
    for (int c = 0; c < 5; c++) {
      final o = Offset(30 + c * 10.0, 57);
      canvas.drawCircle(o, 3.6, _p(const Color(0xFFFFE3EA)));
      canvas.drawCircle(o, 3.6, _p(const Color(0xFFE8446D), style: PaintingStyle.stroke, w: 1.8));
    }
  }

  void _battery(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(const Color(0xFFE2EDFB)));
    // petir
    canvas.drawPath(_bolt(22, 28, 2.2), _p(const Color(0xFFFFC928)));
    canvas.drawPath(_bolt(74, 28, 2.2), _p(const Color(0xFFFFC928)));
    // tutup baterai
    canvas.drawRRect(_rr(43, 20, 57, 28, 3), _p(const Color(0xFF4A4A57)));
    // badan
    canvas.drawRRect(_rr(33, 26, 67, 78, 9), _p(const Color(0xFF9BCB5A)));
    canvas.drawRRect(_rr(33, 26, 67, 44, 9), _p(const Color(0xFFB5DB7C)));
    // mata
    final eye = _p(const Color(0xFF2E3B2A));
    canvas.drawArc(const Rect.fromLTWH(38, 44, 9, 9), 3.14, 3.14, true, eye);
    canvas.drawArc(const Rect.fromLTWH(53, 44, 9, 9), 3.14, 3.14, true, eye);
    // senyum
    canvas.drawArc(const Rect.fromLTWH(43, 54, 14, 10), 0.2, 2.7, false,
        _p(const Color(0xFF2E3B2A), style: PaintingStyle.stroke, w: 2));
  }

  void _scale(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(const Color(0xFFDDF1FB)));
    canvas.drawRRect(_rr(26, 30, 76, 76, 11), _p(Colors.black.withValues(alpha: 0.07)));
    canvas.drawRRect(_rr(24, 26, 76, 74, 11), _p(const Color(0xFF5B97B8)));
    // panel putih setengah lingkaran
    final panel = Path()
      ..moveTo(36, 46)
      ..arcTo(const Rect.fromLTWH(34, 28, 32, 32), 3.14, 3.14, false)
      ..lineTo(64, 46)
      ..close();
    canvas.drawPath(panel, _p(Colors.white));
    // jarum
    canvas.drawLine(const Offset(50, 46), const Offset(55, 37),
        _p(const Color(0xFFE8446D), style: PaintingStyle.stroke, w: 2.4));
    canvas.drawCircle(const Offset(50, 46), 2.4, _p(const Color(0xFF3F7A99)));
    // tanda
    final tick = _p(const Color(0xFFB7C7D3), style: PaintingStyle.stroke, w: 1.4);
    canvas.drawLine(const Offset(40, 40), const Offset(43, 41.5), tick);
    canvas.drawLine(const Offset(60, 40), const Offset(57, 41.5), tick);
  }

  void _hearts(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(const Color(0xFFE6D3EC)));
    canvas.drawPath(_heart(const Offset(60, 54), 22), _p(const Color(0xFF8E5BB5)));
    canvas.drawPath(_heart(const Offset(42, 48), 24), _p(const Color(0xFFE0607E)));
    // kilau
    canvas.drawArc(const Rect.fromLTWH(26, 33, 12, 12), 3.5, 1.4, false,
        _p(Colors.white.withValues(alpha: 0.7), style: PaintingStyle.stroke, w: 2.4));
  }

  void _underwear(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(const Color(0xFFE6D6F0)));
    final body = Path()
      ..moveTo(22, 36)
      ..lineTo(78, 36)
      ..cubicTo(76, 52, 66, 62, 56, 70)
      ..quadraticBezierTo(50, 74, 44, 70)
      ..cubicTo(34, 62, 24, 52, 22, 36)
      ..close();
    canvas.drawPath(body, _p(const Color(0xFF86A98A)));
    // pinggang
    canvas.drawRRect(_rr(21, 33, 79, 41, 4), _p(const Color(0xFF6E9573)));
    // tetes
    final drop = Path()
      ..moveTo(50, 46)
      ..quadraticBezierTo(57, 56, 50, 62)
      ..quadraticBezierTo(43, 56, 50, 46)
      ..close();
    canvas.drawPath(drop, _p(Colors.white));
  }

  void _contraception(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _p(const Color(0xFFF8C8D5)));
    // blister pil
    canvas.save();
    canvas.translate(46, 44);
    canvas.rotate(-0.35);
    canvas.translate(-46, -44);
    canvas.drawRRect(_rr(18, 26, 74, 62, 6), _p(const Color(0xFFBFD9F2)));
    canvas.drawRRect(_rr(18, 26, 74, 62, 6),
        _p(const Color(0xFF8DBBE8), style: PaintingStyle.stroke, w: 1.6));
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 5; c++) {
        canvas.drawCircle(Offset(26 + c * 10.0, 34 + r * 10.0), 3.2, _p(Colors.white));
      }
    }
    canvas.restore();
    // cincin
    canvas.drawCircle(const Offset(68, 70), 11,
        _p(const Color(0xFF5B97B8), style: PaintingStyle.stroke, w: 4));
    // pil
    canvas.save();
    canvas.translate(30, 74);
    canvas.rotate(-0.6);
    canvas.drawRRect(_rr(-9, -4.5, 9, 4.5, 4.5), _p(Colors.white));
    canvas.drawRRect(_rr(0, -4.5, 9, 4.5, 4.5), _p(const Color(0xFFE8446D)));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoalPainter oldDelegate) => oldDelegate.id != id;
}