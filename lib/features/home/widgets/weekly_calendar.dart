import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/painters/dashed_circle_painter.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../calendar/models/calendar_day.dart';

/// Strip kalender seminggu (Minggu sampai Sabtu) yang mengikuti hari ini
/// dan sinkron dengan data log period dari CycleProvider.
class WeeklyCalendar extends StatefulWidget {
  const WeeklyCalendar({Key? key}) : super(key: key);

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  static const _dayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _scheduleMidnightRefresh();
  }

  /// Supaya kalau aplikasi dibiarkan terbuka lewat tengah malam,
  /// strip otomatis pindah ke hari yang baru.
  void _scheduleMidnightRefresh() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
          () {
        if (!mounted) return;
        setState(() {});
        _scheduleMidnightRefresh();
      },
    );
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // weekday: Senin=1 ... Minggu=7 -> (% 7) membuat Minggu = 0
    final startOfWeek = DateTime(today.year, today.month, today.day - (today.weekday % 7));
    final week = List.generate(
      7,
          (i) => DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final date = week[i];
          final isToday = date == today;

          return Column(
            children: [
              Text(
                _dayLabels[i],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 10),
              _buildDateBadge(
                date: date,
                isToday: isToday,
                type: cycle.dayTypeFor(date),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDateBadge({
    required DateTime date,
    required bool isToday,
    required CalendarDayType type,
  }) {
    const double size = 36;

    Color? fillColor;
    Color textColor = AppColors.darkText;
    bool isFertile = false;

    switch (type) {
      case CalendarDayType.period:
        fillColor = AppColors.period;
        textColor = Colors.white;
        break;
      case CalendarDayType.predictPeriod:
        fillColor = AppColors.predictPeriod;
        textColor = Colors.white;
        break;
      case CalendarDayType.fertile:
        isFertile = true;
        break;
      case CalendarDayType.none:
        break;
    }

    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        // Hari ini selalu diberi cincin ungu
        border: isToday ? Border.all(color: AppColors.primaryPurple, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );

    if (isFertile) {
      return CustomPaint(
        size: const Size(size, size),
        painter: const DashedCirclePainter(color: AppColors.fertile),
        child: badge,
      );
    }
    return badge;
  }
}
