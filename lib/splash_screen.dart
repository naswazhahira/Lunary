import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Design System Colors
  static const Color primaryColor = Color(0xFF6C5CE7);     // Ungu Utama
  static const Color secondaryColor = Color(0xFFC7B8ED);   // Ungu Muda
  static const Color accentPinkColor = Color(0xFFE17DA0);  // Pink / Rose
  static const Color darkTextColor = Color(0xFF2E2A4A);    // Dark Text
  static const Color whiteColor = Colors.white;            // Putih

  late AnimationController _controller;

  // Animations
  late Animation<double> _dotsRotation;
  late Animation<double> _dotsRadius;
  late Animation<double> _dotsOpacity;

  late Animation<double> _crescentScale;
  late Animation<double> _crescentOpacity;

  late Animation<double> _textOpacity;

  // Smooth Color Transition Animations
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _titleTextColorAnimation;
  late Animation<Color?> _subtitleTextColorAnimation;
  late Animation<double> _logoWhiteTransition;

  @override
  void initState() {
    super.initState();

    // Durasi total dinaikkan dari 3200ms ke 4200ms (+1 detik)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    // 1. TAHAP TITIK-TITIK BERPUTAR (0% - 35% durasi)
    _dotsRotation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeInOutCubic),
      ),
    );

    _dotsRadius = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.35, curve: Curves.easeInBack),
      ),
    );

    _dotsOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.35, curve: Curves.easeOut),
      ),
    );

    // 2. TAHAP MUNCUL BULAN GRADASI (30% - 50% durasi)
    _crescentScale = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.52, curve: Curves.easeOutBack),
      ),
    );

    _crescentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.42, curve: Curves.easeIn),
      ),
    );

    // 3. TAHAP TRANSISI WARNA SMOOTH KE UNGU & LOGO JADI PUTIH
    // Dimulai dari 58% sampai 78% (Mebuat bulan gradasi 'tahan' +1 detik lebih lama)
    _backgroundColorAnimation = ColorTween(
      begin: whiteColor,
      end: primaryColor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.78, curve: Curves.easeInOut),
      ),
    );

    _titleTextColorAnimation = ColorTween(
      begin: primaryColor,
      end: whiteColor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.78, curve: Curves.easeInOut),
      ),
    );

    _subtitleTextColorAnimation = ColorTween(
      begin: Colors.black45,
      end: secondaryColor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.78, curve: Curves.easeInOut),
      ),
    );

    _logoWhiteTransition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.80, curve: Curves.easeInOut),
      ),
    );

    // 4. TAHAP TEKS & TAGLINE (75% - 95% durasi)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.95, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 4500), () {
      // TODO: Navigasi ke halaman berikutnya
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.reset();
        _controller.forward();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: _backgroundColorAnimation.value,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Area Animasi Logo
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // --- LAYER 1: Titik-titik (Cycle Ring) ---
                        if (_dotsOpacity.value > 0)
                          Opacity(
                            opacity: _dotsOpacity.value,
                            child: Transform.rotate(
                              angle: _dotsRotation.value,
                              child: CustomPaint(
                                size: const Size(120, 120),
                                painter: _CycleRingPainter(
                                  shrinkFactor: _dotsRadius.value,
                                  primaryColor: primaryColor,
                                  secondaryColor: secondaryColor,
                                  accentPinkColor: accentPinkColor,
                                  darkTextColor: darkTextColor,
                                ),
                              ),
                            ),
                          ),

                        // --- LAYER 2: Crescent Ring (Transisi ke Putih) ---
                        if (_crescentOpacity.value > 0)
                          Opacity(
                            opacity: _crescentOpacity.value,
                            child: Transform.scale(
                              scale: _crescentScale.value,
                              child: CustomPaint(
                                size: const Size(90, 90),
                                painter: _CrescentMarkPainter(
                                  primaryColor: primaryColor,
                                  secondaryColor: secondaryColor,
                                  accentPinkColor: accentPinkColor,
                                  whiteProgress: _logoWhiteTransition.value,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // --- LAYER 3: Wordmark & Tagline ---
                  Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Text(
                          'lunary',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w600,
                            color: _titleTextColorAnimation.value,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'period and cycle tracker',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _subtitleTextColorAnimation.value,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  final double shrinkFactor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentPinkColor;
  final Color darkTextColor;

  _CycleRingPainter({
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
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) => true;
}

class _CrescentMarkPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentPinkColor;
  final double whiteProgress;

  _CrescentMarkPainter({
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
  bool shouldRepaint(covariant _CrescentMarkPainter oldDelegate) {
    return oldDelegate.whiteProgress != whiteProgress;
  }
}