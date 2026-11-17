import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/painters/dashed_circle_painter.dart';
import '../../../core/services/cloud_sync.dart';
import '../../../core/services/tracker_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../home/screens/home_screen.dart';

// -----------------------------------------------------------------------------
// Helper umum
// -----------------------------------------------------------------------------

BoxDecoration _bgDecoration() => BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white,
      Color.lerp(Colors.white, AppColors.primaryPink, 0.07)!,
      Color.lerp(Colors.white, AppColors.primaryPurple, 0.12)!,
    ],
    stops: const [0.0, 0.6, 1.0],
  ),
);

Widget _pinkButton(String label, VoidCallback? onPressed, {double? width}) {
  return SizedBox(
    width: width ?? double.infinity,
    height: 52,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPink,
        disabledBackgroundColor: AppColors.primaryPink.withValues(alpha: 0.35),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );
}

// -----------------------------------------------------------------------------
// Layar "Ready to start prioritizing your health with Lunary?"
// -----------------------------------------------------------------------------

class OnboardingReadyPage extends StatefulWidget {
  final VoidCallback onReady;

  const OnboardingReadyPage({Key? key, required this.onReady}) : super(key: key);

  @override
  State<OnboardingReadyPage> createState() => _OnboardingReadyPageState();
}

class _OnboardingReadyPageState extends State<OnboardingReadyPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watchTheme();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(Colors.white, AppColors.primaryPink, 0.22)!,
            Color.lerp(Colors.white, AppColors.primaryPink, 0.06)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _SkyPainter())),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                _bubble(),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _float,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, -8 * Curves.easeInOut.transform(_float.value)),
                    child: child,
                  ),
                  child: SizedBox(
                    width: 200,
                    height: 220,
                    child: CustomPaint(painter: _MascotPainter()),
                  ),
                ),
                const Spacer(flex: 3),
                _pinkButton("I'm ready", widget.onReady, width: 210),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Text(
            'Ready to start prioritizing your health with Lunary?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              height: 1.3,
            ),
          ),
        ),
        CustomPaint(size: const Size(28, 14), painter: _TailPainter()),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SkyPainter extends CustomPainter {
  void _cloud(Canvas c, Offset o, double s, Paint p) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(o.dx, o.dy + 14 * s, 80 * s, 24 * s),
        Radius.circular(12 * s),
      ),
      p,
    );
    c.drawCircle(Offset(o.dx + 26 * s, o.dy + 16 * s), 16 * s, p);
    c.drawCircle(Offset(o.dx + 48 * s, o.dy + 10 * s), 20 * s, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.75);
    _cloud(canvas, Offset(size.width * 0.04, size.height * 0.08), 1.0, cloud);
    _cloud(canvas, Offset(size.width * 0.66, size.height * 0.04), 1.2, cloud);
    _cloud(canvas, Offset(size.width * 0.74, size.height * 0.2), 0.7, cloud);

    final hill = Paint()
      ..color = Color.lerp(Colors.white, AppColors.primaryPink, 0.14)!;
    canvas.drawOval(
      Rect.fromLTWH(-size.width * 0.2, size.height * 0.78, size.width * 0.9, size.height * 0.4),
      hill,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.82, size.width * 1.0, size.height * 0.4),
      hill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MascotPainter extends CustomPainter {
  void _spark(Canvas c, Offset o, double r, Color col) {
    final p = Path()
      ..moveTo(o.dx, o.dy - r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx + r, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx - r, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r)
      ..close();
    c.drawPath(p, Paint()..color = col);
  }

  void _arm(Canvas c, Offset a, Offset b, Offset ctrl, Color color) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);
    c.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round,
    );
    c.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200);

    final purple = AppColors.primaryPurple;
    final light = Color.lerp(Colors.white, purple, 0.45)!;
    const dark = Color(0xFF2E2A4A);

    // bayangan tanah
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 212), width: 96, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );

    // tangan terangkat
    _arm(canvas, const Offset(40, 134), const Offset(14, 86), const Offset(12, 120), light);
    _arm(canvas, const Offset(160, 134), const Offset(186, 86), const Offset(188, 120), light);

    // kaki
    for (final x in [78.0, 122.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 196), width: 34, height: 20), Paint()..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 196), width: 26, height: 14), Paint()..color = light);
    }

    // badan (stiker putih + gradien)
    const center = Offset(100, 124);
    canvas.drawCircle(center, 73, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      66,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, purple],
        ).createShader(Rect.fromCircle(center: center, radius: 66)),
    );

    // mata
    for (final x in [78.0, 122.0]) {
      final eye = Rect.fromCenter(center: Offset(x, 116), width: 18, height: 22);
      canvas.drawOval(eye, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x + 1, 118), 6.5, Paint()..color = dark);
      canvas.drawCircle(Offset(x + 3, 115), 2, Paint()..color = Colors.white);
      canvas.drawArc(
        eye,
        math.pi * 1.05,
        math.pi * 0.9,
        false,
        Paint()
          ..color = dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // pipi
    final blush = Paint()..color = AppColors.primaryPink.withValues(alpha: 0.45);
    canvas.drawOval(Rect.fromCenter(center: const Offset(64, 138), width: 16, height: 9), blush);
    canvas.drawOval(Rect.fromCenter(center: const Offset(136, 138), width: 16, height: 9), blush);

    // senyum
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(100, 138), width: 26, height: 18),
      0.25,
      math.pi - 0.5,
      false,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // kilau
    _spark(canvas, const Offset(30, 40), 10, AppColors.primaryPink);
    _spark(canvas, const Offset(172, 30), 12, purple.withValues(alpha: 0.8));
    _spark(canvas, const Offset(152, 66), 6, AppColors.primaryPink.withValues(alpha: 0.8));
    _spark(canvas, const Offset(52, 70), 6, purple.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Alur setelah survei: gejala -> tinggi -> berat -> komitmen -> Welcome -> Home
// -----------------------------------------------------------------------------

class _Symptom {
  final String id;
  final String label;
  final IconData icon;
  const _Symptom(this.id, this.label, this.icon);
}

const List<_Symptom> _symptomList = [
  _Symptom('cramps', 'Cramps', Icons.waves_rounded),
  _Symptom('fatigue', 'Fatigue', Icons.battery_2_bar_rounded),
  _Symptom('bloating', 'Bloating', Icons.bubble_chart_rounded),
  _Symptom('tender_breasts', 'Tender breasts', Icons.favorite_rounded),
  _Symptom('backache', 'Backache', Icons.accessibility_new_rounded),
  _Symptom('none', 'None of these', Icons.block_rounded),
];

class OnboardingExtrasFlow extends StatefulWidget {
  final String firstName;
  final String email;

  /// true: setelah selesai layar ini hanya ditutup (alur dari Profile/dialog).
  /// false: setelah selesai langsung ke Home.
  final bool returnToCaller;

  const OnboardingExtrasFlow({
    Key? key,
    required this.firstName,
    required this.email,
    this.returnToCaller = false,
  }) : super(key: key);

  @override
  State<OnboardingExtrasFlow> createState() => _OnboardingExtrasFlowState();
}

class _OnboardingExtrasFlowState extends State<OnboardingExtrasFlow> {
  int _step = 0; // 0 gejala, 1 tinggi, 2 berat, 3 komitmen

  final Set<String> _symptoms = {};

  bool _isMetric = true;
  int _heightCm = 160;
  bool _heightSet = false;
  double _weightKg = 55;
  bool _weightSet = false;

  int get _totalIn => (_heightCm / 2.54).round();

  void _setFtIn({int? ft, int? inch}) {
    final f = ft ?? _totalIn ~/ 12;
    final i = inch ?? _totalIn % 12;
    setState(() => _heightCm = ((f * 12 + i) * 2.54).round());
  }

  void _back() {
    if (_step > 0 && _step < 3) setState(() => _step--);
  }

  void _next() {
    if (_step == 2) unawaited(_save());
    setState(() => _step++);
  }

  Future<void> _save() async {
    final email = widget.email;
    if (email.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'onboarding_${email.toLowerCase()}_symptoms',
      _symptoms.toList(),
    );

    // Format sama dengan yang dibaca Profile (height/weight sesuai satuan isMetric)
    final profile = <String, dynamic>{...?CloudSync.profile};
    profile['isMetric'] = _isMetric;
    profile['symptoms'] = _symptoms.toList();
    if (_heightSet) {
      profile['height'] = _isMetric ? '$_heightCm' : '$_totalIn';
    }
    if (_weightSet) {
      profile['weight'] =
      _isMetric ? '${_weightKg.round()}' : '${(_weightKg * 2.2046226).round()}';
      // Ikut tercatat di grafik berat badan
      await TrackerStore.setValue(
        email,
        TrackerType.weight,
        DateTime.now(),
        double.parse(_weightKg.toStringAsFixed(1)),
      );
    }
    CloudSync.pushProfile(profile);
  }

  void _done() {
    if (!mounted) return;
    if (widget.returnToCaller) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watchTheme();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _step == 3
            ? _CommitPage(firstName: widget.firstName, onDone: _done)
            : Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _bgDecoration(),
          child: SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _stepBody(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _symptomsPage();
      case 1:
        return _heightPage();
      default:
        return _weightPage();
    }
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: _step > 0
                ? IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
            )
                : null,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: (_step + 1) / 4),
                duration: const Duration(milliseconds: 300),
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: AppColors.primaryPink.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: _next,
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Gejala
  // ---------------------------------------------------------------------------

  Widget _symptomsPage() {
    final title = widget.firstName.isEmpty
        ? 'How do you feel today?'
        : '${widget.firstName}, how do you feel today?';

    return Column(
      key: const ValueKey('page_symptoms'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Column(
              children: [
                const Text(
                  'Your cycle can impact how you feel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.darkerSubText),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                    height: 1.25,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Select your symptoms',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkerSubText,
                  ),
                ),
                const SizedBox(height: 22),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.82,
                  children: _symptomList.map(_symptomItem).toList(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
          child: _pinkButton('Next', _symptoms.isEmpty ? null : _next),
        ),
      ],
    );
  }

  Widget _symptomItem(_Symptom s) {
    final selected = _symptoms.contains(s.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (s.id == 'none') {
            if (selected) {
              _symptoms.remove('none');
            } else {
              _symptoms
                ..clear()
                ..add('none');
            }
          } else {
            _symptoms.remove('none');
            if (selected) {
              _symptoms.remove(s.id);
            } else {
              _symptoms.add(s.id);
            }
          }
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPink.withValues(alpha: selected ? 0.22 : 0.10),
              border: selected
                  ? Border.all(color: AppColors.primaryPink, width: 3)
                  : null,
            ),
            child: Icon(
              s.icon,
              size: 32,
              color: s.id == 'none' ? AppColors.subText : AppColors.primaryPink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tinggi
  // ---------------------------------------------------------------------------

  String get _heightLabel =>
      _isMetric ? '$_heightCm cm' : '${_totalIn ~/ 12} ft ${_totalIn % 12} in';

  Widget _heightPage() {
    return Column(
      key: const ValueKey('page_height'),
      children: [
        const SizedBox(height: 28),
        const Text(
          'How tall are you?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Adding your height helps us improve your cycle predictions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.darkerSubText, height: 1.4),
          ),
        ),
        const SizedBox(height: 24),
        _valueBox(_heightLabel),
        const SizedBox(height: 16),
        _unitToggle(),
        Expanded(
          child: _pickerArea(
            _isMetric
                ? [
              _Wheel(
                key: const ValueKey('h_cm'),
                min: 120,
                max: 220,
                initial: _heightCm,
                onChanged: (v) => setState(() => _heightCm = v),
              ),
              _unitLabel('cm'),
            ]
                : [
              _Wheel(
                key: const ValueKey('h_ft'),
                min: 3,
                max: 7,
                initial: _totalIn ~/ 12,
                width: 80,
                onChanged: (v) => _setFtIn(ft: v),
              ),
              _unitLabel('ft'),
              _Wheel(
                key: const ValueKey('h_in'),
                min: 0,
                max: 11,
                initial: _totalIn % 12,
                width: 80,
                onChanged: (v) => _setFtIn(inch: v),
              ),
              _unitLabel('in'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: _pinkButton('Next', () {
            _heightSet = true;
            _next();
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Berat
  // ---------------------------------------------------------------------------

  String get _weightLabel => _isMetric
      ? '${_weightKg.round()} kg'
      : '${(_weightKg * 2.2046226).round()} lb';

  Widget _weightPage() {
    return Column(
      key: const ValueKey('page_weight'),
      children: [
        const SizedBox(height: 28),
        const Text(
          'How much do you weigh?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Your weight helps us personalize your insights. You can change it anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.darkerSubText, height: 1.4),
          ),
        ),
        const SizedBox(height: 24),
        _valueBox(_weightLabel),
        const SizedBox(height: 16),
        _unitToggle(),
        Expanded(
          child: _pickerArea(
            _isMetric
                ? [
              _Wheel(
                key: const ValueKey('w_kg'),
                min: 30,
                max: 200,
                initial: _weightKg.round(),
                onChanged: (v) => setState(() => _weightKg = v.toDouble()),
              ),
              _unitLabel('kg'),
            ]
                : [
              _Wheel(
                key: const ValueKey('w_lb'),
                min: 66,
                max: 440,
                initial: (_weightKg * 2.2046226).round(),
                onChanged: (v) => setState(() => _weightKg = v / 2.2046226),
              ),
              _unitLabel('lb'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: _pinkButton('Next', () {
            _weightSet = true;
            _next();
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Komponen tinggi/berat
  // ---------------------------------------------------------------------------

  Widget _valueBox(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _unitToggle() {
    Widget seg(String t, bool metric) {
      final sel = _isMetric == metric;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _isMetric = metric),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: sel ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: sel
                  ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: Center(
              child: Text(
                t,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: sel ? AppColors.darkText : AppColors.subText,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryPink.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [seg('Metric (cm, kg)', true), seg('Imperial (ft, lb)', false)]),
    );
  }

  Widget _pickerArea(List<Widget> children) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: children),
      ],
    );
  }

  Widget _unitLabel(String t) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 14),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkerSubText,
        ),
      ),
    );
  }
}

class _Wheel extends StatefulWidget {
  final int min;
  final int max;
  final int initial;
  final double width;
  final ValueChanged<int> onChanged;

  const _Wheel({
    Key? key,
    required this.min,
    required this.max,
    required this.initial,
    required this.onChanged,
    this.width = 110,
  }) : super(key: key);

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final FixedExtentScrollController _c;
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial.clamp(widget.min, widget.max).toInt();
    _c = FixedExtentScrollController(initialItem: _selected - widget.min);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 260,
      child: ListWheelScrollView.useDelegate(
        controller: _c,
        itemExtent: 54,
        diameterRatio: 1.8,
        perspective: 0.003,
        overAndUnderCenterOpacity: 0.35,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (i) {
          HapticFeedback.selectionClick();
          setState(() => _selected = widget.min + i);
          widget.onChanged(widget.min + i);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.max - widget.min + 1,
          builder: (context, i) {
            final n = widget.min + i;
            final sel = n == _selected;
            return Center(
              child: Text(
                '$n',
                style: TextStyle(
                  fontSize: sel ? 30 : 22,
                  fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                  color: sel ? AppColors.darkText : AppColors.subText,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Komitmen: tahan logo -> getar -> Welcome to Lunary!
// -----------------------------------------------------------------------------

class _CommitPage extends StatefulWidget {
  final String firstName;
  final VoidCallback onDone;

  const _CommitPage({Key? key, required this.firstName, required this.onDone})
      : super(key: key);

  @override
  State<_CommitPage> createState() => _CommitPageState();
}

class _CommitPageState extends State<_CommitPage> with TickerProviderStateMixin {
  late final AnimationController _hold;
  late final AnimationController _fill;
  Timer? _haptic;
  Timer? _exit;
  bool _welcome = false;
  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _hold = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _completed();
      });
    _fill = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  }

  @override
  void dispose() {
    _haptic?.cancel();
    _exit?.cancel();
    _hold.dispose();
    _fill.dispose();
    super.dispose();
  }

  void _press() {
    if (_welcome) return;
    _hold.forward();
    _haptic?.cancel();
    // Getaran makin kuat seiring lamanya ditahan
    _haptic = Timer.periodic(const Duration(milliseconds: 60), (_) {
      final v = _hold.value;
      if (v < 0.3) {
        HapticFeedback.selectionClick();
      } else if (v < 0.65) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _release() {
    if (_welcome) return;
    _haptic?.cancel();
    _hold.animateBack(0, duration: const Duration(milliseconds: 450));
  }

  void _completed() {
    if (_welcome) return;
    _haptic?.cancel();
    HapticFeedback.heavyImpact();
    setState(() => _welcome = true);
    _fill.forward();
    _exit = Timer(const Duration(milliseconds: 3000), widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    final intro = widget.firstName.isEmpty
        ? 'I will use Lunary to'
        : 'I, ${widget.firstName}, will use Lunary to';

    return LayoutBuilder(
      builder: (context, cons) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _bgDecoration(),
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      Text(
                        intro,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'understand my cycle, know my body better and be ready for anything.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.darkerSubText,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      _holdButton(),
                      const SizedBox(height: 24),
                      Text(
                        'Tap and hold on the Lunary logo to commit.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryPink,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              if (_welcome) Positioned.fill(child: _welcomeOverlay(cons)),
            ],
          ),
        );
      },
    );
  }

  Widget _holdButton() {
    return Listener(
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedBuilder(
        animation: _hold,
        builder: (_, __) {
          final v = _hold.value;
          final shake = Offset(
            (_rnd.nextDouble() - 0.5) * 6 * v,
            (_rnd.nextDouble() - 0.5) * 6 * v,
          );

          return Transform.translate(
            offset: shake,
            child: Transform.scale(
              scale: 1 + 0.2 * v,
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // pendar yang membesar
                    Container(
                      width: 140 + 50 * v,
                      height: 140 + 50 * v,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryPink.withValues(alpha: 0.10 + 0.12 * v),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: 0.25 + 0.3 * v),
                            blurRadius: 30 + 30 * v,
                            spreadRadius: 6 + 14 * v,
                          ),
                        ],
                      ),
                    ),
                    // cincin progres
                    CustomPaint(
                      size: const Size(176, 176),
                      painter: _RingPainter(v, AppColors.primaryPurple),
                    ),
                    // logo
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryPink, AppColors.primaryPurple],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(112, 112),
                            painter: DashedCirclePainter(
                              color: Colors.white.withValues(alpha: 0.7),
                              strokeWidth: 2,
                              dashCount: 24,
                            ),
                          ),
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: CustomPaint(
                              painter: LunaryCrescentPainter(baseColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _welcomeOverlay(BoxConstraints cons) {
    return AnimatedBuilder(
      animation: _fill,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_fill.value.clamp(0.0, 1.0).toDouble());
        final textT = ((_fill.value - 0.45) / 0.55).clamp(0.0, 1.0).toDouble();

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FillPainter(
                  t,
                  AppColors.primaryPink,
                  Offset(cons.maxWidth / 2, cons.maxHeight * 0.58),
                ),
              ),
            ),
            Opacity(
              opacity: textT,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Welcome to Lunary!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _fill.value * 3,
                            child: CustomPaint(
                              size: const Size(120, 120),
                              painter: DashedCirclePainter(
                                color: Colors.white,
                                strokeWidth: 2.5,
                                dashCount: 24,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CustomPaint(
                              painter: LunaryCrescentPainter(baseColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  final Color color;

  _RingPainter(this.v, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * v,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.v != v || old.color != color;
}

class _FillPainter extends CustomPainter {
  final double t;
  final Color color;
  final Offset center;

  _FillPainter(this.t, this.color, this.center);

  @override
  void paint(Canvas canvas, Size size) {
    final maxR = math.sqrt(size.width * size.width + size.height * size.height);
    canvas.drawCircle(center, maxR * t, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FillPainter old) => old.t != t;
}