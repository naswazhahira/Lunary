enum CalendarDayType { none, period, predictPeriod, fertile }

class CalendarDay {
  final int day;
  final CalendarDayType type;
  final bool isOvulation;

  const CalendarDay({
    required this.day,
    this.type = CalendarDayType.none,
    this.isOvulation = false,
  });

  CalendarDay copyWith({
    int? day,
    CalendarDayType? type,
    bool? isOvulation,
  }) {
    return CalendarDay(
      day: day ?? this.day,
      type: type ?? this.type,
      isOvulation: isOvulation ?? this.isOvulation,
    );
  }
}
