import 'dart:async';
import '../widgets/goal_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/services/cloud_sync.dart';
import '../../home/screens/home_screen.dart';
import '../../survey/screens/cycle_survey_screen.dart';

/// Penyimpanan jawaban onboarding (tahun lahir & tujuan) per akun.
class OnboardingStore {
  OnboardingStore._();

  static String _key(String email, String field) =>
      'onboarding_${email.toLowerCase()}_$field';

  static Future<void> save(String email, int? birthYear, List<String> goals) async {
    if (email.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (birthYear != null) {
      await prefs.setInt(_key(email, 'birthYear'), birthYear);
    }
    await prefs.setStringList(_key(email, 'goals'), goals);

    // Ikut disimpan ke profil di cloud (digabung dengan data profil yang ada)
    CloudSync.pushProfile({
      ...?CloudSync.profile,
      'birthYear': birthYear,
      'goals': goals,
    });
  }

  static Future<int?> birthYear(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(email, 'birthYear'));
  }

  static Future<List<String>> goals(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key(email, 'goals')) ?? const [];
  }
}

class _Goal {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const _Goal(this.id, this.label, this.icon, this.color);
}

const List<_Goal> _goals = [
  _Goal('get_pregnant', 'Get pregnant', Icons.child_friendly_outlined, Color(0xFF9B7EDE)),
  _Goal('already_pregnant', "I'm already pregnant", Icons.pregnant_woman_rounded, Color(0xFFED5589)),
  _Goal('track_period', 'Track my period', Icons.calendar_month_rounded, Color(0xFF4FA3E0)),
  _Goal('wellbeing', 'Charge my well-being', Icons.bolt_rounded, Color(0xFF7CC35A)),
  _Goal('weight', 'Manage my weight', Icons.monitor_weight_outlined, Color(0xFF3F8FB5)),
  _Goal('sex_life', 'Enhance my sex life', Icons.favorite_border_rounded, Color(0xFFB06AB3)),
  _Goal('discharge', 'Decode my discharge', Icons.water_drop_outlined, Color(0xFF6FA27A)),
  _Goal('contraception', 'Explore contraception', Icons.medication_outlined, Color(0xFFE8739B)),
];

/// Onboarding akun baru: Nice to meet you -> tahun lahir -> tujuan -> Survei.
class OnboardingFlowScreen extends StatefulWidget {
  final String name;
  final String email;

  /// false (default): setelah survei langsung ke Home (dipakai Splash & LoginGate).
  /// true: setelah survei kembali ke layar pemanggil (dipakai alur dari Profile/dialog).
  final bool returnToCaller;

  const OnboardingFlowScreen({
    Key? key,
    required this.name,
    required this.email,
    this.returnToCaller = false,
  }) : super(key: key);

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _step = 0; // 0 welcome, 1 tahun lahir, 2 tujuan
  bool _finishing = false;
  Timer? _welcomeTimer;

  late final int _minYear;
  late final int _maxYear;
  late int _birthYear;
  late final FixedExtentScrollController _yearWheel;

  final Set<String> _selectedGoals = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().year;
    _minYear = now - 70;
    _maxYear = now - 10;
    _birthYear = (now - 25).clamp(_minYear, _maxYear).toInt();
    _yearWheel = FixedExtentScrollController(initialItem: _birthYear - _minYear);

    // Tutup SnackBar sisa dari layar sebelumnya (mis. "Registration successful!")
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    });

    // Sedikit lebih lama supaya animasi welcome sempat terbaca
    _welcomeTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted && _step == 0) setState(() => _step = 1);
    });
  }

  @override
  void dispose() {
    _welcomeTimer?.cancel();
    _yearWheel.dispose();
    super.dispose();
  }

  /// Nama depan dengan huruf kapital di awal: "grace" / "GRACE" -> "Grace".
  String get _firstName {
    final n = widget.name.trim();
    if (n.isEmpty || n == 'Lunary User' || n.startsWith('+')) return '';
    final first = n.split(RegExp(r'\s+')).first;
    if (first.isEmpty) return '';
    return first[0].toUpperCase() + first.substring(1).toLowerCase();
  }

  void _back() {
    if (_step == 2) setState(() => _step = 1);
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;

    await OnboardingStore.save(widget.email, _birthYear, _selectedGoals.toList());
    if (!mounted) return;

    final nav = Navigator.of(context);

    if (widget.returnToCaller) {
      // Survei menutup dirinya sendiri, lalu onboarding ikut ditutup
      await nav.push(MaterialPageRoute(builder: (_) => const CycleSurveyScreen()));
      if (mounted) nav.pop();
    } else {
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (_) => CycleSurveyScreen(
            onFinished: () {
              nav.pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ),
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
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // Putih di atas, semburat pink dan ungu sangat muda di bawah
          decoration: BoxDecoration(
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
          ),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _buildStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _WelcomeContent(
          key: const ValueKey('step_welcome'),
          firstName: _firstName,
        );
      case 1:
        return _buildBirthYear();
      default:
        return _buildGoals();
    }
  }

  // ---------------------------------------------------------------------------
  // Layar 2: tahun lahir
  // ---------------------------------------------------------------------------

  Widget _buildBirthYear() {
    final count = _maxYear - _minYear + 1;

    return Padding(
      key: const ValueKey('step_year'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Log your year of birth to make the predictions better',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: _yearWheel,
                  itemExtent: 64,
                  diameterRatio: 1.7,
                  perspective: 0.003,
                  overAndUnderCenterOpacity: 0.3,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _birthYear = _minYear + index);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: count,
                    builder: (context, index) {
                      final year = _minYear + index;
                      final selected = year == _birthYear;
                      return Center(
                        child: Text(
                          '$year',
                          style: TextStyle(
                            fontSize: selected ? 34 : 28,
                            fontWeight: FontWeight.w800,
                            color: selected ? AppColors.darkText : AppColors.subText,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _primaryButton('Next', () => setState(() => _step = 2)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Layar 3: What can we help you do?
  // ---------------------------------------------------------------------------

  Widget _buildGoals() {
    return Column(
      key: const ValueKey('step_goals'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
              ),
              const Spacer(),
              TextButton(
                onPressed: _finishing ? null : _finish,
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
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              children: [
                const Text(
                  'What can we help you do?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Choose as many as you'd like.",
                  style: TextStyle(fontSize: 15, color: AppColors.darkerSubText),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: _goals.map(_buildGoalCard).toList(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: _primaryButton(
            'Continue',
            _selectedGoals.isEmpty || _finishing ? null : _finish,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(_Goal g) {
    final selected = _selectedGoals.contains(g.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (selected) {
            _selectedGoals.remove(g.id);
          } else {
            _selectedGoals.add(g.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPurple.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryPurple : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GoalIllustration(id: g.id, size: 76),
            const SizedBox(height: 12),
            Text(
              g.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          disabledBackgroundColor: AppColors.primaryPink.withValues(alpha: 0.35),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Layar welcome: lingkaran berpendar (scale + fade-in) dan sapaan
// -----------------------------------------------------------------------------

class _WelcomeContent extends StatefulWidget {
  final String firstName;

  const _WelcomeContent({Key? key, required this.firstName}) : super(key: key);

  @override
  State<_WelcomeContent> createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<_WelcomeContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _circleFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _circleScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _circleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.firstName.isEmpty
        ? 'Nice to meet you!'
        : 'Nice to meet you, ${widget.firstName}!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _circleFade,
              child: ScaleTransition(
                scale: _circleScale,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryPink, AppColors.primaryPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // Pendar lembut senada dengan gradien
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.35),
                        blurRadius: 36,
                        spreadRadius: 2,
                        offset: const Offset(-6, 8),
                      ),
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.35),
                        blurRadius: 40,
                        spreadRadius: 2,
                        offset: const Offset(8, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: CustomPaint(
                        painter: LunaryCrescentPainter(baseColor: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _subtitleFade,
              child: const Text(
                "Let's personalize Lunary for your cycle.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.darkerSubText,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}