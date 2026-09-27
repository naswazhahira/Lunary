import 'package:flutter/material.dart';
import '../../features/calendar/models/calendar_day.dart';

/// Shared cycle data used by Home, Calendar, and Cycle Insights.
class CycleProvider extends ChangeNotifier {
  static const int averageCycleLength = 28;
  static const int periodLength = 7;
  static const int lutealPhaseLength = 14;

  final Set<DateTime> loggedPeriodDates = {};
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime get selectedMonth => _selectedMonth;
  DateTime get selectedDate => _selectedDate;

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  void goToPrevMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = _normalize(date);
    notifyListeners();
  }

  bool get isSelectedDatePeriod => loggedPeriodDates.contains(_selectedDate);

  bool get canTrackSelectedDate => !_selectedDate.isAfter(_normalize(DateTime.now()));

  /// Cek apakah ada catatan haid di sekitar tanggal yang dipilih
  bool _hasNearbyPeriod(DateTime date) {
    for (int offset = -periodLength; offset <= periodLength; offset++) {
      if (loggedPeriodDates.contains(date.add(Duration(days: offset)))) {
        return true;
      }
    }
    return false;
  }

  void togglePeriodForSelectedDate() {
    if (!canTrackSelectedDate) return;

    if (loggedPeriodDates.contains(_selectedDate)) {
      loggedPeriodDates.remove(_selectedDate);
    } else {
      if (_hasNearbyPeriod(_selectedDate)) {
        loggedPeriodDates.add(_selectedDate);
      } else {
        final start = _selectedDate;
        final today = _normalize(DateTime.now());
        final rawEnd = start.add(const Duration(days: periodLength - 1));
        final end = rawEnd.isAfter(today) ? today : rawEnd;

        DateTime cursor = start;
        while (!cursor.isAfter(end)) {
          loggedPeriodDates.add(cursor);
          cursor = cursor.add(const Duration(days: 1));
        }
      }
    }
    notifyListeners();
  }

  void logPeriodToday() {
    final today = _normalize(DateTime.now());
    if (loggedPeriodDates.contains(today)) {
      loggedPeriodDates.remove(today);
    } else {
      loggedPeriodDates.add(today);
    }
    notifyListeners();
  }

  /// Mencari tanggal awal periode haid terakhir yang dicatat
  DateTime? get lastPeriodStartDate {
    if (loggedPeriodDates.isEmpty) return null;
    final sorted = loggedPeriodDates.toList()..sort();
    DateTime start = sorted.last;
    for (int i = sorted.length - 2; i >= 0; i--) {
      if (start.difference(sorted[i]).inDays == 1) {
        start = sorted[i];
      } else {
        break;
      }
    }
    return start;
  }

  /// Prediksi Tanggal Ovulasi Terdekat MASA DEPAN / HARI INI (untuk Cycle Status)
  DateTime? get nextOvulationDateFromToday {
    final start = lastPeriodStartDate;
    if (start == null) return null;

    final today = _normalize(DateTime.now());
    DateTime ovDate = start.add(Duration(days: averageCycleLength - lutealPhaseLength));

    while (ovDate.isBefore(today)) {
      ovDate = ovDate.add(const Duration(days: averageCycleLength));
    }
    return ovDate;
  }

  /// Prediksi Tanggal Haid Berikutnya Terdekat MASA DEPAN / HARI INI (untuk Cycle Status)
  DateTime? get nextPeriodStartDateFromToday {
    final start = lastPeriodStartDate;
    if (start == null) return null;

    final today = _normalize(DateTime.now());
    DateTime nextStart = start.add(const Duration(days: averageCycleLength));

    while (nextStart.isBefore(today)) {
      nextStart = nextStart.add(const Duration(days: averageCycleLength));
    }
    return nextStart;
  }

  int get currentCycleDay {
    final start = lastPeriodStartDate;
    if (start == null) return 1;
    return _normalize(DateTime.now()).difference(start).inDays + 1;
  }

  String get currentPhaseLabel {
    final today = _normalize(DateTime.now());
    if (loggedPeriodDates.contains(today)) return 'Period';

    final nextOvulation = nextOvulationDateFromToday;
    if (nextOvulation != null) {
      final fertileStart = nextOvulation.subtract(const Duration(days: 4));
      final fertileEnd = nextOvulation.add(const Duration(days: 1));
      if (!today.isBefore(fertileStart) && !today.isAfter(fertileEnd)) {
        return 'Fertile Window';
      }
      if (today.isAfter(fertileEnd)) return 'Luteal Phase';
    }
    return 'Follicular Phase';
  }

  /// Hitungan sisa hari ke haid berikutnya (pasti >= 0, berbasis hari ini)
  int? get daysUntilNextPeriod {
    final next = nextPeriodStartDateFromToday;
    if (next == null) return null;
    final diff = next.difference(_normalize(DateTime.now())).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Hitungan sisa hari ke ovulasi berikutnya (pasti >= 0, berbasis hari ini)
  int? get daysUntilOvulation {
    final ov = nextOvulationDateFromToday;
    if (ov == null) return null;
    final diff = ov.difference(_normalize(DateTime.now())).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get periodFraction => periodLength / averageCycleLength;
  double get lutealFraction => lutealPhaseLength / averageCycleLength;
  double get fertileFraction => 5 / averageCycleLength;
  double get follicularFraction => 1 - periodFraction - fertileFraction - lutealFraction;

  double get todayCycleProgress => ((currentCycleDay - 1) % averageCycleLength) / averageCycleLength;
  double get ovulationCycleProgress => (averageCycleLength - lutealPhaseLength) / averageCycleLength;

  /// Render Kalender Keseluruhan (Masa Lalu, Sekarang, & Prediksi Berulang di Masa Depan)
  List<CalendarDay> get currentMonthDays {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final baseStart = lastPeriodStartDate;

    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);

      CalendarDayType type = CalendarDayType.none;
      bool isOvulationDay = false;

      // 1. Cek jika tanggal ini di-log sebagai haid riil oleh user
      if (loggedPeriodDates.contains(date)) {
        type = CalendarDayType.period;
      } else if (baseStart != null) {
        // 2. Hitung proyeksi siklus berulang (past & future) untuk rendering kalender
        final diffDays = date.difference(baseStart).inDays;
        if (diffDays > 0) {
          final cycleOffset = diffDays % averageCycleLength;

          // Rentang Prediksi Haid (Hari ke-0 sampai ke-6 siklus)
          if (cycleOffset >= 0 && cycleOffset < periodLength) {
            type = CalendarDayType.predictPeriod;
          }
          // Rentang Masa Subur (Fertile Window)
          else if (cycleOffset >= (averageCycleLength - lutealPhaseLength - 4) &&
              cycleOffset <= (averageCycleLength - lutealPhaseLength + 1)) {
            type = CalendarDayType.fertile;
          }

          // Hari Puncak Ovulasi
          if (cycleOffset == (averageCycleLength - lutealPhaseLength)) {
            isOvulationDay = true;
          }
        }
      }

      return CalendarDay(day: day, type: type, isOvulation: isOvulationDay);
    });
  }
}
