import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../navigation/app_navigation.dart';

class AppBottomNavBar extends StatelessWidget {
  final AppNavTab currentTab;
  final ValueChanged<AppNavTab> onTabSelected;

  const AppBottomNavBar({
    Key? key,
    required this.currentTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {
        'tab': AppNavTab.cycle,
        'icon': Icons.water_drop_outlined,
        'activeIcon': Icons.water_drop,
        'label': 'Cycle',
      },
      {
        'tab': AppNavTab.calendar,
        'icon': Icons.calendar_today_outlined,
        'activeIcon': Icons.calendar_today_rounded,
        'label': 'Calendar',
      },
      {
        'tab': AppNavTab.lunaryAi,
        'icon': 'custom_moon',
        'activeIcon': 'custom_moon',
        'label': 'Lunary AI',
      },
      {
        'tab': AppNavTab.insights,
        'icon': Icons.menu_book_rounded,
        'activeIcon': Icons.menu_book_rounded,
        'label': 'Insights',
      },
      {
        'tab': AppNavTab.profile,
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'label': 'Profile',
      },
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
        children: navItems.map((item) {
          final tab = item['tab'] as AppNavTab;
          final isSelected = currentTab == tab;
          final color = isSelected ? AppColors.navActive : AppColors.navInactive;

          return GestureDetector(
            onTap: () => onTabSelected(tab),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item['label'] == 'Lunary AI')
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: LunaryCrescentPainter(baseColor: color),
                    ),
                  )
                else
                  Icon(
                    isSelected
                        ? item['activeIcon'] as IconData
                        : item['icon'] as IconData,
                    color: color,
                    size: 24,
                  ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Custom Painter yang menggunakan logika potongan persis CrescentMarkPainter Splash Screen
class LunaryCrescentPainter extends CustomPainter {
  final Color baseColor;

  LunaryCrescentPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Lingkaran luar (Outer Circle)
    final Path outerCircle = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    // 2. Lingkaran pemotong dalam (Inner Cutout) - Logika persis dari Splash Screen
    final double innerMargin = size.width * 0.13;
    final Path innerCutout = Path()
      ..addOval(Rect.fromLTWH(
        innerMargin * 2,
        innerMargin,
        size.width - (innerMargin * 2),
        size.height - (innerMargin * 2),
      ));

    // 3. Gabungkan selisih path
    final Path crescentPath = Path.combine(
      PathOperation.difference,
      outerCircle,
      innerCutout,
    );

    canvas.drawPath(crescentPath, paint);
  }

  @override
  bool shouldRepaint(covariant LunaryCrescentPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor;
}
