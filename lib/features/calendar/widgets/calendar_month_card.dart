import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/painters/dashed_circle_painter.dart';
import '../models/calendar_day.dart';

class CalendarMonthCard extends StatelessWidget {
  final DateTime month;
  final List<CalendarDay> days;
  final DateTime selectedDate;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDaySelected;

  const CalendarMonthCard({
    Key? key,
    required this.month,
    required this.days,
    required this.selectedDate,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  }) : super(key: key);

  static const _monthNames = [
    'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
    'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER',
  ];
  static const _weekdayLabels = ['MING', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) => _buildDayGrid(constraints.maxWidth),
          ),
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
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.calendarNumber,
        ),
      ))
          .toList(),
    );
  }

  Widget _buildDayGrid(double availableWidth) {
    final cellSlot = availableWidth / 7;
    final circleSize = (cellSlot - 8).clamp(28.0, 40.0);

    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final dayLookup = {for (final d in days) d.day: d};
    final now = DateTime.now();

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
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: week
                .map((day) => SizedBox(
              width: cellSlot,
              child: Center(child: _buildDayCell(day, now, circleSize)),
            ))
                .toList(),
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildDayCell(CalendarDay? day, DateTime now, double size) {
    if (day == null) return SizedBox(width: size, height: size);

    final cellDate = DateTime(month.year, month.month, day.day);
    final isToday = cellDate.year == now.year &&
        cellDate.month == now.month &&
        cellDate.day == now.day;
    final isSelected = cellDate.year == selectedDate.year &&
        cellDate.month == selectedDate.month &&
        cellDate.day == selectedDate.day;

    Widget circle;
    switch (day.type) {
      case CalendarDayType.period:
        circle = _filledCircle(size, AppColors.period, day.day, Colors.white);
        break;
      case CalendarDayType.predictPeriod:
        circle = _filledCircle(size, AppColors.predictPeriod, day.day, Colors.white);
        break;
      case CalendarDayType.fertile:
      // Tampilkan Dashed Circle + Border Ungu jika tanggal ini adalah Hari Ini (Today)
        circle = Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: const DashedCirclePainter(color: AppColors.fertile),
            ),
            if (isToday)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryPurple, width: 2),
                ),
              ),
            _numberText(day.day, AppColors.calendarNumber, size),
          ],
        );
        break;
      case CalendarDayType.none:
        circle = isToday
            ? Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: AppColors.primaryPurple, width: 2),
            ),
          ),
          child: Center(
            child: _numberText(day.day, AppColors.calendarNumber, size),
          ),
        )
            : SizedBox(
          width: size,
          height: size,
          child: Center(
            child: _numberText(day.day, AppColors.calendarNumber, size),
          ),
        );
        break;
    }

    if (day.isOvulation) {
      circle = Stack(
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

    return GestureDetector(
      onTap: () => onDaySelected(cellDate),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primaryPurple.withOpacity(0.15) : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppColors.primaryPurple, width: 1.5)
              : null,
        ),
        child: Center(child: circle),
      ),
    );
  }

  Widget _filledCircle(double size, Color color, int day, Color textColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: _numberText(day, textColor, size)),
    );
  }

  Widget _numberText(int day, Color color, double cellSize) {
    return Text(
      '$day',
      style: TextStyle(
        fontSize: cellSize * 0.38,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
