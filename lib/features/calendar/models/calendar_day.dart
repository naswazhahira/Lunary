/// Which "state" a calendar day is in. Drives fill color / border
/// style in [CalendarMonthCard].
enum CalendarDayType { none, period, predictPeriod, fertile }

class CalendarDay {
  final int day;
  final CalendarDayType type;
  final bool isOvulation;
  final bool isToday;

  const CalendarDay({
    required this.day,
    this.type = CalendarDayType.none,
    this.isOvulation = false,
    this.isToday = false,
  });
}

/// TODO: replace this with real cycle data from your state
/// management / backend. For now it returns the mock data shown in
/// the design reference for September 2026, and an empty list (plain
/// calendar, no markers) for every other month.
List<CalendarDay> mockCalendarDaysFor(DateTime month) {
  if (month.year == 2026 && month.month == 9) {
    return [
      const CalendarDay(day: 10, isOvulation: true),
      const CalendarDay(day: 19, type: CalendarDayType.period),
      const CalendarDay(day: 20, type: CalendarDayType.period),
      const CalendarDay(day: 21, type: CalendarDayType.period),
      // Diubah dari predictPeriod ke period
      const CalendarDay(day: 22, type: CalendarDayType.period),
      const CalendarDay(day: 23, type: CalendarDayType.period),
      const CalendarDay(day: 24, type: CalendarDayType.period),
      const CalendarDay(day: 25, type: CalendarDayType.period),
      const CalendarDay(day: 26, isToday: true),
      const CalendarDay(day: 28, type: CalendarDayType.fertile),
      const CalendarDay(day: 29, type: CalendarDayType.fertile),
      const CalendarDay(day: 30, type: CalendarDayType.fertile),
    ];
  }
  return const [];
}
