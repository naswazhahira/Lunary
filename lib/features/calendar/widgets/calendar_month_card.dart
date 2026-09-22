import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/painters/dashed_circle_painter.dart';
import '../models/calendar_day.dart';

class CalendarMonthCard extends StatelessWidget {
  final DateTime month;
  final List<CalendarDay> days;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const CalendarMonthCard({
    Key? key,
    required this.month,
    required this.days,
    required this.onPrevMonth,
    required this.onNextMonth,
  }) : super(key: key);

  static const _monthNames = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];
  static const _weekdayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
      child: Column(
        children: [
          _buildMonthHeader(),
          const SizedBox(height: 20),
          _buildWeekdayRow(),
          const SizedBox(height: 12),
          _buildDayGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevMonth,
          icon: const Icon(Icons.chevron_left, color: AppColors.primaryPurple),
        ),
        Text(
          '${_monthNames[month.month - 1]} ${month.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryPurple,
            letterSpacing: 0.5,
          ),
        ),
        IconButton(
          onPressed: onNextMonth,
          icon: const Icon(Icons.chevron_right, color: AppColors.primaryPurple),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _weekdayLabels
          .map((label) => Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ))
          .toList(),
    );
  }

  Widget _buildDayGrid() {
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7; // Sun = 0
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final dayLookup = {for (final d in days) d.day: d};

    final cells = <CalendarDay?>[
      ...List.filled(firstWeekday, null),
      for (int d = 1; d <= daysInMonth; d++) dayLookup[d] ?? CalendarDay(day: d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final week = cells.sublist(i, i + 7);
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((day) => _buildDayCell(day)).toList(),
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildDayCell(CalendarDay? day) {
    const double size = 36;
    if (day == null) return const SizedBox(width: size, height: size);

    Widget circle;
    switch (day.type) {
      case CalendarDayType.period:
        circle = _filledCircle(size, AppColors.period, day.day, Colors.white);
        break;
      case CalendarDayType.predictPeriod:
        circle = _filledCircle(size, AppColors.predictPeriod, day.day, Colors.white);
        break;
      case CalendarDayType.fertile:
        circle = Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(size, size),
              painter: DashedCirclePainter(color: AppColors.fertile),
            ),
            _numberText(day.day, AppColors.darkText),
          ],
        );
        break;
      case CalendarDayType.none:
        circle = day.isToday
            ? Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryPurple, width: 2),
          ),
          child: Center(child: _numberText(day.day, AppColors.darkText)),
        )
            : SizedBox(
          width: size,
          height: size,
          child: Center(child: _numberText(day.day, AppColors.darkText)),
        );
        break;
    }

    if (!day.isOvulation) return circle;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        circle,
        Positioned(
          top: -2,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.ovulation,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filledCircle(double size, Color color, int day, Color textColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: _numberText(day, textColor)),
    );
  }

  Widget _numberText(int day, Color color) {
    return Text(
      '$day',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
