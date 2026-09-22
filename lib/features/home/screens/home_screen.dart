import 'dart:math' as math;
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Color Palette
  static const Color primaryPink = Color(0xFFED5589);
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color darkTextColor = Color(0xFF4A3E62);
  static const Color subTextColor = Color(0xFF8E82A3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E7FC), // Gradient ungu lembut atas
              Color(0xFFFCEBF3), // Gradient pink lembut bawah
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildCalendarStrip(),
                      const SizedBox(height: 32),
                      _buildCycleRingWidget(),
                      const SizedBox(height: 32),
                      _buildArticleCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. HEADER WIDGET
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hi, Awa',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Lorem ipsum dolor sit amet',
              style: TextStyle(
                fontSize: 14,
                color: subTextColor,
              ),
            ),
          ],
        ),
        // Tombol profil bulat
        Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Color(0xFFB197FC),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. CALENDAR STRIP WIDGET
  Widget _buildCalendarStrip() {
    final days = [
      {'day': 'SUN', 'date': '22', 'type': 'filled'},
      {'day': 'MON', 'date': '23', 'type': 'filled'},
      {'day': 'TUE', 'date': '24', 'type': 'filled'},
      {'day': 'WED', 'date': '25', 'type': 'filled'},
      {'day': 'THU', 'date': '26', 'type': 'outlined'},
      {'day': 'FRI', 'date': '27', 'type': 'normal'},
      {'day': 'SAT', 'date': '28', 'type': 'dashed'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((item) {
          return Column(
            children: [
              Text(
                item['day']!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 10),
              _buildDateBadge(item['date']!, item['type']!),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateBadge(String date, String type) {
    const double size = 36;

    if (type == 'filled') {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: primaryPink,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            date,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else if (type == 'outlined') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryPurple, width: 2),
        ),
        child: Center(
          child: Text(
            date,
            style: const TextStyle(
              color: darkTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else if (type == 'dashed') {
      return CustomPaint(
        size: const Size(size, size),
        painter: DashedCirclePainter(color: primaryPurple),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              date,
              style: const TextStyle(
                color: darkTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            date,
            style: const TextStyle(
              color: darkTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
  }

  // 3. CYCLE RING WIDGET
  Widget _buildCycleRingWidget() {
    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(250, 250),
              painter: MainCycleRingPainter(progress: 0.68),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Fertile window',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: darkTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '2 days',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'low chance of getting pregnant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: subTextColor,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. ARTICLE CARD WIDGET
  Widget _buildArticleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tips Kesehatan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryPink,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.bookmark_border, size: 20, color: subTextColor),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cara Menjaga Mood & Energi Saat Memasuki Fase Folikuler',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pelajari nutrisi dan jenis olahraga ringan yang cocok untuk menjaga staminamu minggu ini.',
            style: TextStyle(
              fontSize: 13,
              color: subTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 5. BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar() {
    final navItems = [
      {'icon': Icons.water_drop_outlined, 'activeIcon': Icons.water_drop, 'label': 'Cycle'},
      {'icon': Icons.calendar_today_outlined, 'activeIcon': Icons.calendar_today, 'label': 'Calendar'},
      {'icon': Icons.nightlight_round_outlined, 'activeIcon': Icons.nightlight_round, 'label': 'Lunary AI'},
      {'icon': Icons.menu_book_outlined, 'activeIcon': Icons.menu_book, 'label': 'Insights'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? navItems[index]['activeIcon'] as IconData
                      : navItems[index]['icon'] as IconData,
                  color: isSelected ? primaryPurple : subTextColor,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  navItems[index]['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primaryPurple : subTextColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// CUSTOM PAINTERS (Ring Chart & Dashed Border)
class MainCycleRingPainter extends CustomPainter {
  final double progress;

  MainCycleRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 26.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    // Outer Background (Putih)
    final Paint bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Active Progress Arc (Pink)
    final Paint activePaint = Paint()
      ..color = const Color(0xFFED5589)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Dimulai dari kanan atas (-45 derajat)
    double startAngle = -math.pi / 3;
    double sweepAngle = (2 * math.pi) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DashedCirclePainter extends CustomPainter {
  final Color color;

  DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    const int dashCount = 14;
    const double dashAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - 1),
          i * dashAngle,
          dashAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}