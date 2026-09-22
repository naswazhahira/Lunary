import 'dart:math' as math;
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Color palette
  static const Color primaryPink = Color(0xFFED5589);
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color darkTextColor = Color(0xFF2E2A4A);
  static const Color subTextColor = Color(0xFF8E82A3);
  static const Color darkerSubTextColor = Color(0xFF6E6A8A);

  // Fungsi pop up
  void _showImageBackgroundPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // bg foto
                Positioned.fill(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1518895949257-7621c3c786d7?q=80&w=600&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
                // overlay putih semi transparan
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
                // konten pop up
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E7FC),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFFED5589),
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Catat Gejala Hari Ini?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mencatat kondisi tubuh secara rutin membantu Lunary AI memberikan prediksi siklus yang lebih akurat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: darkerSubTextColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.8),
                              ),
                              child: const Text(
                                'Nanti Saja',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8E82A3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: primaryPink,
                              ),
                              child: const Text(
                                'Catat Sekarang',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // gradasi dari kiri ke kanan
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFE2DCF7),
              Color(0xFFEFE8F9),
              Color(0xFFF9E9EE),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
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
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildCalendarStrip(),
                            const SizedBox(height: 36),
                            _buildCycleRingWidget(),
                            const SizedBox(height: 32),
                            _buildSectionHeader('Artikel & Tips Untukmu', () {}),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                      // list horzintal artikel dengan foto di sisi kiri
                      _buildHorizontalArticleList(),
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

  // header widget
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hi, Awa',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryPink.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Fase Folikuler',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryPink,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '•',
                    style: TextStyle(
                      fontSize: 12,
                      color: darkerSubTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Hari ke-8',
                    style: TextStyle(
                      fontSize: 13,
                      color: darkerSubTextColor,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => _showImageBackgroundPopup(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: darkTextColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB197FC),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB197FC).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // calendar strip widget
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
          child: Text(date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
          child: Text(date, style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
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
            child: Text(date, style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(date, style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      );
    }
  }

  // cycle ring widget
  Widget _buildCycleRingWidget() {
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
                painter: MainCycleRingPainter(progress: 0.65),
              ),
            ),
            Positioned(
              top: 75,
              child: Column(
                children: const [
                  Text(
                    'Fertile window',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: darkTextColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '2 days',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: darkTextColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 140,
                    child: Text(
                      'low chance of getting pregnant',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: darkerSubTextColor,
                        height: 1.2,
                      ),
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

  // header yg kecil untuk section artikel
  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkTextColor,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  // horizontal scroll artikel
  Widget _buildHorizontalArticleList() {
    final articles = [
      {
        'category': 'Tips Kesehatan',
        'title': 'Cara Menjaga Mood & Energi Saat Fase Folikuler',
        'desc': 'Pelajari nutrisi & olahraga ringan yang tepat...',
        'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=400&auto=format&fit=crop',
      },
      {
        'category': 'Nutrisi',
        'title': 'Makanan Kaya Zat Besi untuk Stamina Tubuh',
        'desc': 'Rekomendasi menu sehat harian terbaik...',
        'image': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=400&auto=format&fit=crop',
      },
      {
        'category': 'Olahraga',
        'title': 'Jenis Yoga Ringan Selama Siklus Berjalan',
        'desc': 'Peregangan aman untuk merilekskan otot...',
        'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=400&auto=format&fit=crop',
      },
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
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // foto di sebelah kiri card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        article['image'] as String,
                        width: 95,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // konten teks artikel
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primaryPink.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article['category'] as String,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryPink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article['title'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article['desc'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: darkerSubTextColor,
                              fontWeight: FontWeight.w400,
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

  // bottom navigator
  Widget _buildBottomNavigationBar() {
    const Color activeNavColor = Color(0xFF6C5CE7);
    const Color inactiveNavColor = Color(0xFFB197FC);

    final navItems = [
      {'icon': Icons.water_drop_outlined, 'activeIcon': Icons.water_drop, 'label': 'Cycle'},
      {'icon': Icons.calendar_today_outlined, 'activeIcon': Icons.calendar_today_rounded, 'label': 'Calendar'},
      {'icon': 'custom_moon', 'activeIcon': 'custom_moon', 'label': 'Lunary AI'},
      {'icon': Icons.menu_book_rounded, 'activeIcon': Icons.menu_book_rounded, 'label': 'Insights'},
      {'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
          final color = isSelected ? activeNavColor : inactiveNavColor;

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
                if (navItems[index]['label'] == 'Lunary AI')
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: LunaryCrescentPainter(
                        baseColor: color,
                        crescentColor: const Color(0xFFF3E7FC),
                      ),
                    ),
                  )
                else
                  Icon(
                    isSelected
                        ? navItems[index]['activeIcon'] as IconData
                        : navItems[index]['icon'] as IconData,
                    color: color,
                    size: 24,
                  ),
                const SizedBox(height: 6),
                Text(
                  navItems[index]['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: color,
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

// widget navigasi tombol
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BounceButton({Key? key, required this.child, required this.onTap}) : super(key: key);

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// custom painters
class MainCycleRingPainter extends CustomPainter {
  final double progress;

  MainCycleRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 34.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    final Paint bgPaint = Paint()
      ..color = const Color(0xFFEAE1F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final Paint activePaint = Paint()
      ..color = const Color(0xFFED5589)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    double startAngle = math.pi * 0.75;
    double sweepAngle = (2 * math.pi) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );

    final double endAngle = startAngle + sweepAngle;
    final double dotX = center.dx + radius * math.cos(endAngle);
    final double dotY = center.dy + radius * math.sin(endAngle);
    final Offset dotCenter = Offset(dotX, dotY);

    canvas.drawCircle(dotCenter, 14, Paint()..color = Colors.white);
    canvas.drawCircle(dotCenter, 9, Paint()..color = const Color(0xFFED5589));
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

// painter bulan sabit
class LunaryCrescentPainter extends CustomPainter {
  final Color baseColor;
  final Color crescentColor;

  LunaryCrescentPainter({
    required this.baseColor,
    required this.crescentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    final Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, basePaint);

    final Path outerCrescentCircle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius * 0.72));

    final double cutOffsetX = radius * 0.32;
    final double cutOffsetY = -radius * 0.10;
    final Path innerCutCircle = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(center.dx + cutOffsetX, center.dy + cutOffsetY),
        radius: radius * 0.62,
      ));

    final Path crescentPath = Path.combine(
      PathOperation.difference,
      outerCrescentCircle,
      innerCutCircle,
    );

    final Paint crescentPaint = Paint()
      ..color = crescentColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(crescentPath, crescentPaint);
  }

  @override
  bool shouldRepaint(covariant LunaryCrescentPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor ||
          oldDelegate.crescentColor != crescentColor;
}
