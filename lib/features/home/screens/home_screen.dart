import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/widgets/app_profile_avatar.dart';
import '../../../core/widgets/app_notification_button.dart';
import '../../../core/widgets/bounce_button.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/providers/cycle_provider.dart';
import '../widgets/weekly_calendar.dart';
import '../../insights/models/article_model.dart';
import '../../insights/screens/article_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showImageBackgroundPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1518895949257-7621c3c786d7?q=80&w=600&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(child: Container(color: Colors.white.withOpacity(0.88))),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(color: Color(0xFFF3E7FC), shape: BoxShape.circle),
                        child: const Center(child: Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 30)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Log Your Symptoms Today?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Logging how your body feels regularly helps Lunary AI give you more accurate cycle predictions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.darkerSubText, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                backgroundColor: Colors.white.withOpacity(0.8),
                              ),
                              child: const Text('Maybe Later', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.subText)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<CycleProvider>().logPeriodToday();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                backgroundColor: AppColors.primaryPink,
                              ),
                              child: const Text('Log Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, cycle),
                            const SizedBox(height: 20),
                            const WeeklyCalendar(),
                            const SizedBox(height: 36),
                            _buildCycleRingWidget(cycle),
                            const SizedBox(height: 32),
                            _buildSectionHeader(
                              'Articles & Tips for You',
                                  () => handleAppNavTap(context, AppNavTab.insights),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                      _buildHorizontalArticleList(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              AppBottomNavBar(
                currentTab: AppNavTab.cycle,
                onTabSelected: (tab) => handleAppNavTap(context, tab),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CycleProvider cycle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hi, Awa', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkText, letterSpacing: -0.5, height: 1.1)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Text(cycle.currentPhaseLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryPink, height: 1.0)),
                  ),
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(fontSize: 12, color: AppColors.darkerSubText, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('Day ${cycle.currentCycleDay}', style: const TextStyle(fontSize: 13, color: AppColors.darkerSubText, fontWeight: FontWeight.w500, height: 1.0)),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            AppNotificationButton(onTap: () => _showImageBackgroundPopup(context)),
            const SizedBox(width: 10),
            AppProfileAvatar(onTap: () => handleAppNavTap(context, AppNavTab.profile)),
          ],
        ),
      ],
    );
  }

  /// Ring arc color based on today's cycle phase
  Color _ringColorFor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.period:
        return AppColors.period;
      case CyclePhase.fertile:
        return AppColors.primaryPurple;
      case CyclePhase.none:
      case CyclePhase.follicular:
      case CyclePhase.luteal:
        return AppColors.primaryPink;
    }
  }

  Widget _buildCycleRingWidget(CycleProvider cycle) {
    final hasData = cycle.hasCycleData;
    final phase = cycle.currentPhase;

    final String titleText = hasData ? cycle.currentPhaseLabel : 'No data yet';
    final String valueText = hasData ? 'Day ${cycle.currentCycleDay}' : '--';
    final String subtitleText = cycle.pregnancyChanceText;

    return Center(
      child: SizedBox(
        width: 270,
        height: 250,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: MainCycleRingPainter(
                  progress: cycle.phaseProgress, // sebelumnya cycle.ringProgress
                  color: _ringColorFor(phase),
                  showProgress: hasData,
                ),
              ),
            ),
            Positioned(
              top: 75,
              child: Column(
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valueText,
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.darkText),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 140,
                    child: Text(
                      subtitleText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.darkerSubText, height: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text('See All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryPurple)),
        ),
      ],
    );
  }

  Widget _buildHorizontalArticleList(BuildContext context) {
    final List<Article> articles = [
      Article(
        category: 'Health Tips',
        title: 'How to Keep Your Mood & Energy Up During the Follicular Phase',
        summary: 'Learn the right nutrition & light exercise...',
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600&auto=format&fit=crop',
        content:
        'The follicular phase starts on the first day of your period and lasts until ovulation. As estrogen rises, many people notice more energy, better focus, and a brighter mood.\n\n'
            'Make the Most of Your Energy\n'
            'This is a great time to start new projects, try more challenging workouts, and be social. Your body recovers faster during this phase, so strength training and cardio feel easier.\n\n'
            'Nutrition Tips\n'
            '- Eat iron-rich foods such as spinach, lean beef, and lentils to replenish what you lost during your period.\n'
            '- Add fresh vegetables, fermented foods, and whole grains to support rising estrogen levels.\n'
            '- Stay hydrated throughout the day.\n\n'
            'Light Exercise Ideas\n'
            'Brisk walking, cycling, swimming, and yoga flows are all good choices. Listen to your body and rest when you need to.',
      ),
      Article(
        category: 'Nutrition',
        title: 'Iron-Rich Foods to Boost Your Stamina',
        summary: 'The best healthy daily menu recommendations...',
        imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=600&auto=format&fit=crop',
        content:
        'Iron is essential for producing red blood cells that carry oxygen throughout your body. During your period, you lose iron through bleeding, which can leave you feeling tired, dizzy, or weak.\n\n'
            'Best Iron Sources\n'
            '- Spinach, kale, and other leafy greens\n'
            '- Lean red meat, chicken, and liver\n'
            '- Lentils, chickpeas, and kidney beans\n'
            '- Tofu, tempeh, and pumpkin seeds\n'
            '- Eggs and fortified cereals\n\n'
            'Boost Absorption\n'
            'Pair iron-rich foods with vitamin C, such as oranges, strawberries, tomatoes, or bell peppers. Try to avoid drinking tea or coffee with your meals, as they can reduce iron absorption.\n\n'
            'If you often feel extremely tired or look pale, talk to a doctor about checking for iron deficiency.',
      ),
      Article(
        category: 'Exercise',
        title: 'Gentle Yoga Poses for Your Cycle',
        summary: 'Safe stretches to relax your muscles...',
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600&auto=format&fit=crop',
        content:
        'Gentle movement improves blood circulation in the pelvic area and can ease cramps, bloating, and tension without overloading your body.\n\n'
            '1. Child\'s Pose (Balasana)\n'
            'Sit back on your heels and lower your chest toward the floor, arms extended forward. This stretches the lower back and relaxes the hips.\n\n'
            '2. Cat-Cow Pose\n'
            'On hands and knees, alternate between arching and rounding your spine. It loosens the spine and gently massages the abdominal muscles.\n\n'
            '3. Reclining Butterfly Pose\n'
            'Lie on your back, bring the soles of your feet together, and let your knees fall open. This opens the hips and calms the nervous system.\n\n'
            '4. Legs-Up-the-Wall Pose\n'
            'Rest your legs against a wall for 5 to 10 minutes to relieve heaviness and lower back discomfort.\n\n'
            'Hold each pose for 5 to 8 slow breaths, and stop if anything feels painful.',
      ),
    ];

    return SizedBox(
      height: 135,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Container(
            width: 310,
            margin: const EdgeInsets.only(right: 14),
            child: BounceButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(
                      article: article,
                      // Rekomendasi "Read Next": semua artikel Home selain yang dibuka
                      relatedArticles: articles.where((a) => a != article).toList(),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(article.imageUrl, width: 95, height: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                            child: Text(article.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryPink)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText, height: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article.summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.darkerSubText, fontWeight: FontWeight.w400),
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
}

class MainCycleRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool showProgress;

  MainCycleRingPainter({
    required this.progress,
    this.color = AppColors.primaryPink,
    this.showProgress = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 34.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    final Paint bgPaint = Paint()
      ..color = AppColors.cycleRingTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // No log data yet: show the empty track only
    if (!showProgress) return;

    final Paint activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final double startAngle = math.pi * 0.75;
    final double sweepAngle = (2 * math.pi) * progress;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, activePaint);

    final double endAngle = startAngle + sweepAngle;
    final double dotX = center.dx + radius * math.cos(endAngle);
    final double dotY = center.dy + radius * math.sin(endAngle);
    final Offset dotCenter = Offset(dotX, dotY);

    canvas.drawCircle(dotCenter, 14, Paint()..color = Colors.white);
    canvas.drawCircle(dotCenter, 9, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant MainCycleRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.color != color ||
          oldDelegate.showProgress != showProgress;
}
