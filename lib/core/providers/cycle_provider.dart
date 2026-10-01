import 'package:flutter/material.dart';
import '../../features/calendar/models/calendar_day.dart';

/// Fase siklus pada hari ini.
enum CyclePhase { none, period, follicular, fertile, luteal }

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

  /// Apakah user sudah pernah mencatat haid
  bool get hasCycleData => loggedPeriodDates.isNotEmpty;

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

  /// Fase siklus hari ini, dihitung dari data log.
  /// Rumus offset-nya sama dengan dayTypeFor(), jadi Calendar & Home selalu konsisten.
  CyclePhase get currentPhase {
    final today = _normalize(DateTime.now());
    if (loggedPeriodDates.contains(today)) return CyclePhase.period;
    if (lastPeriodStartDate == null) return CyclePhase.none;

    final offset = (currentCycleDay - 1) % averageCycleLength;
    final ovulationOffset = averageCycleLength - lutealPhaseLength;

    if (offset >= ovulationOffset - 4 && offset <= ovulationOffset + 1) {
      return CyclePhase.fertile;
    }
    if (offset > ovulationOffset + 1) return CyclePhase.luteal;
    return CyclePhase.follicular;
  }

  String get currentPhaseLabel {
    switch (currentPhase) {
      case CyclePhase.none:
        return 'No Data';
      case CyclePhase.period:
        return 'Period';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.fertile:
        return 'Fertile Window';
      case CyclePhase.luteal:
        return 'Luteal Phase';
    }
  }

  /// Keterangan peluang hamil untuk teks di tengah ring Home
  String get pregnancyChanceText {
    switch (currentPhase) {
      case CyclePhase.none:
        return 'Log your period in Calendar';
      case CyclePhase.fertile:
        return 'high chance of getting pregnant';
      case CyclePhase.period:
      case CyclePhase.follicular:
      case CyclePhase.luteal:
        return 'low chance of getting pregnant';
    }
  }

  /// Progress ring berdasarkan seluruh siklus (hari ke-N dari 28).
  /// Tidak dipakai lagi oleh ring Home, dipertahankan kalau ada yang masih memakainya.
  double get ringProgress {
    if (!hasCycleData) return 0;
    final dayInCycle = ((currentCycleDay - 1) % averageCycleLength) + 1;
    return dayInCycle / averageCycleLength;
  }

  /// Progress ring Home per FASE: hari ke-N di fase ini / panjang fase ini.
  /// Hari terakhir tiap fase = 1.0 (ring penuh).
  /// Batas fasenya identik dengan currentPhase, jadi tetap konsisten.
  double get phaseProgress {
    if (!hasCycleData) return 0;

    final dayInCycle = ((currentCycleDay - 1) % averageCycleLength) + 1; // 1..28
    final ovulationOffset = averageCycleLength - lutealPhaseLength;      // 14

    // Hari siklus (1-based), diturunkan dari rentang offset di currentPhase
    final fertileStart = ovulationOffset - 4 + 1; // hari 11
    final fertileEnd = ovulationOffset + 1 + 1;   // hari 16
    final lutealStart = fertileEnd + 1;           // hari 17

    int start = 1;
    int length = periodLength;

    switch (currentPhase) {
      case CyclePhase.none:
        return 0;
      case CyclePhase.period:
        start = 1;
        length = periodLength; // 7
        break;
      case CyclePhase.follicular:
        start = periodLength + 1;        // hari 8
        length = fertileStart - start;   // 3 hari
        break;
      case CyclePhase.fertile:
        start = fertileStart;
        length = fertileEnd - fertileStart + 1; // 6 hari
        break;
      case CyclePhase.luteal:
        start = lutealStart;
        length = averageCycleLength - lutealStart + 1; // 12 hari
        break;
    }

    final dayInPhase = dayInCycle - start + 1;
    return (dayInPhase / length).clamp(0.0, 1.0);
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

  /// Tipe hari (haid / prediksi haid / masa subur / biasa) untuk tanggal mana pun.
  /// Dipakai oleh Calendar dan strip mingguan di Home.
  CalendarDayType dayTypeFor(DateTime date) {
    final d = _normalize(date);

    if (loggedPeriodDates.contains(d)) return CalendarDayType.period;

    final baseStart = lastPeriodStartDate;
    if (baseStart == null) return CalendarDayType.none;

    final diffDays = d.difference(baseStart).inDays;
    if (diffDays <= 0) return CalendarDayType.none;

    final cycleOffset = diffDays % averageCycleLength;
    final ovulationOffset = averageCycleLength - lutealPhaseLength;

    // Rentang Prediksi Haid
    if (cycleOffset < periodLength) return CalendarDayType.predictPeriod;

    // Rentang Masa Subur (Fertile Window)
    if (cycleOffset >= ovulationOffset - 4 && cycleOffset <= ovulationOffset + 1) {
      return CalendarDayType.fertile;
    }

    return CalendarDayType.none;
  }

  /// Apakah tanggal ini hari puncak ovulasi
  bool isOvulationDate(DateTime date) {
    final d = _normalize(date);
    if (loggedPeriodDates.contains(d)) return false;

    final baseStart = lastPeriodStartDate;
    if (baseStart == null) return false;

    final diffDays = d.difference(baseStart).inDays;
    if (diffDays <= 0) return false;

    return diffDays % averageCycleLength == (averageCycleLength - lutealPhaseLength);
  }

  /// Render Kalender Keseluruhan (Masa Lalu, Sekarang, & Prediksi Berulang di Masa Depan)
  List<CalendarDay> get currentMonthDays {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);

      return CalendarDay(
        day: day,
        type: dayTypeFor(date),
        isOvulation: isOvulationDate(date),
      );
    });
  }
}
