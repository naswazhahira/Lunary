import 'package:flutter/material.dart';
import '../../features/calendar/models/calendar_day.dart';
import '../services/cycle_settings.dart';

/// Fase siklus pada hari ini.
enum CyclePhase { none, period, follicular, fertile, luteal }

/// Shared cycle data used by Home, Calendar, and Cycle Insights.
class CycleProvider extends ChangeNotifier {
  static const int averageCycleLength = 28;
  static const int periodLength = 7;
  static const int lutealPhaseLength = 14;

  /// Nilai efektif: pakai pengaturan user (survei / Profile) kalau ada,
  /// kalau kosong pakai angka umum (7 / 28 / 14).
  int get periodDays => CycleSettings.periodLength ?? periodLength;
  int get cycleDays => CycleSettings.cycleLength ?? averageCycleLength;
  int get lutealDays => CycleSettings.lutealPhase ?? lutealPhaseLength;

  /// Panggil setelah pengaturan siklus di Profile berubah agar layar ikut refresh.
  void onSettingsChanged() => notifyListeners();

  /// Jarak maksimal (hari) dari awal blok lama agar tap dianggap "koreksi",
  /// bukan siklus baru.
  static const int correctionWindowDays = 10;

  final Set<DateTime> loggedPeriodDates = {};
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime get selectedMonth => _selectedMonth;
  DateTime get selectedDate => _selectedDate;

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  // ---------------------------------------------------------------------------
  // Penyimpanan permanen
  // ---------------------------------------------------------------------------

  /// Simpan tanggal haid ke penyimpanan akun aktif, lalu beri tahu layar.
  void _commit() {
    CycleSettings.saveLoggedDates(loggedPeriodDates);
    notifyListeners();
  }

  /// Ganti data di memori dengan data milik akun yang sedang aktif di
  /// CycleSettings. Panggil setelah CycleSettings.loadFor / loadGuest selesai.
  void reloadFromSettings() {
    loggedPeriodDates
      ..clear()
      ..addAll(CycleSettings.loggedDates);
    notifyListeners();
  }

  /// Dipakai survei: catat haid terakhir mulai [start] sepanjang periodDays hari
  /// (tidak melewati hari ini). Diabaikan kalau sudah ada data haid atau
  /// tanggalnya di masa depan.
  void setInitialPeriod(DateTime start) {
    final s = _normalize(start);
    if (s.isAfter(_normalize(DateTime.now()))) return;
    if (loggedPeriodDates.isNotEmpty) return;

    _addPeriodBlock(s);
    _selectedDate = s;
    _selectedMonth = DateTime(s.year, s.month);
    _commit();
  }

  // ---------------------------------------------------------------------------
  // Navigasi kalender
  // ---------------------------------------------------------------------------

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

  /// Kelompokkan tanggal yang dicatat menjadi blok-blok berurutan.
  List<List<DateTime>> _periodBlocks() {
    final days = loggedPeriodDates.toList()..sort();
    final blocks = <List<DateTime>>[];
    for (final day in days) {
      if (blocks.isNotEmpty && day.difference(blocks.last.last).inDays == 1) {
        blocks.last.add(day);
      } else {
        blocks.add([day]);
      }
    }
    return blocks;
  }

  /// Tambahkan blok haid mulai dari [start] sepanjang periodDays hari
  /// (tidak melewati hari ini).
  void _addPeriodBlock(DateTime start) {
    final today = _normalize(DateTime.now());
    final rawEnd = start.add(Duration(days: periodDays - 1));
    final end = rawEnd.isAfter(today) ? today : rawEnd;

    DateTime cursor = start;
    while (!cursor.isAfter(end)) {
      loggedPeriodDates.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  void togglePeriodForSelectedDate() {
    if (!canTrackSelectedDate) return;
    final date = _selectedDate;

    // Cari blok lama yang berkaitan dengan tanggal ini
    List<DateTime>? target;
    for (final block in _periodBlocks()) {
      final inside = !date.isBefore(block.first) && !date.isAfter(block.last);
      final near = date.difference(block.first).inDays.abs() <= correctionWindowDays;
      final adjacentAfter = date.difference(block.last).inDays == 1;
      if (inside || near || adjacentAfter) {
        target = block;
        break;
      }
    }

    if (target != null) {
      final oldStart = target.first;
      final oldEnd = target.last;
      final isStart = date == oldStart;
      final isInside = !date.isBefore(oldStart) && !date.isAfter(oldEnd);
      final isAdjacentAfter = date.difference(oldEnd).inDays == 1;

      if (isStart) {
        // Tap tanggal awal = undo seluruh blok
        loggedPeriodDates.removeAll(target);
        _commit();
        return;
      }

      if (isInside) {
        for (final d in target) {
          if (!d.isAfter(date)) loggedPeriodDates.remove(d);
        }
        _commit();
        return;
      }

      if (isAdjacentAfter) {
        loggedPeriodDates.add(date);
        _commit();
        return;
      }

      loggedPeriodDates.removeAll(target);
    }

    _addPeriodBlock(date);
    _commit();
  }

  void logPeriodToday() {
    selectDate(DateTime.now());
    togglePeriodForSelectedDate();
  }

  void clearAllData() {
    loggedPeriodDates.clear();
    _commit();
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
    DateTime ovDate = start.add(Duration(days: cycleDays - lutealDays));

    while (ovDate.isBefore(today)) {
      ovDate = ovDate.add(Duration(days: cycleDays));
    }
    return ovDate;
  }

  /// Prediksi Tanggal Haid Berikutnya Terdekat MASA DEPAN / HARI INI (untuk Cycle Status)
  DateTime? get nextPeriodStartDateFromToday {
    final start = lastPeriodStartDate;
    if (start == null) return null;

    final today = _normalize(DateTime.now());
    DateTime nextStart = start.add(Duration(days: cycleDays));

    while (nextStart.isBefore(today)) {
      nextStart = nextStart.add(Duration(days: cycleDays));
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

    final offset = (currentCycleDay - 1) % cycleDays;
    final ovulationOffset = cycleDays - lutealDays;

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

  /// Progress ring berdasarkan seluruh siklus (hari ke-N dari panjang siklus).
  /// Tidak dipakai lagi oleh ring Home, dipertahankan kalau ada yang masih memakainya.
  double get ringProgress {
    if (!hasCycleData) return 0;
    final dayInCycle = ((currentCycleDay - 1) % cycleDays) + 1;
    return dayInCycle / cycleDays;
  }

  /// Progress ring Home per FASE: hari ke-N di fase ini / panjang fase ini.
  /// Hari terakhir tiap fase = 1.0 (ring penuh).
  /// Batas fasenya identik dengan currentPhase, jadi tetap konsisten.
  double get phaseProgress {
    if (!hasCycleData) return 0;

    final dayInCycle = ((currentCycleDay - 1) % cycleDays) + 1; // 1..panjang siklus
    final ovulationOffset = cycleDays - lutealDays;

    // Hari siklus (1-based), diturunkan dari rentang offset di currentPhase
    final fertileStart = ovulationOffset - 4 + 1;
    final fertileEnd = ovulationOffset + 1 + 1;
    final lutealStart = fertileEnd + 1;

    int start = 1;
    int length = periodDays;

    switch (currentPhase) {
      case CyclePhase.none:
        return 0;
      case CyclePhase.period:
        start = 1;
        length = periodDays;
        break;
      case CyclePhase.follicular:
        start = periodDays + 1;
        length = fertileStart - start;
        break;
      case CyclePhase.fertile:
        start = fertileStart;
        length = fertileEnd - fertileStart + 1;
        break;
      case CyclePhase.luteal:
        start = lutealStart;
        length = cycleDays - lutealStart + 1;
        break;
    }

    if (length < 1) length = 1;
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

  double get periodFraction => periodDays / cycleDays;
  double get lutealFraction => lutealDays / cycleDays;
  double get fertileFraction => 5 / cycleDays;
  double get follicularFraction =>
      (1 - periodFraction - fertileFraction - lutealFraction).clamp(0.0, 1.0);

  double get todayCycleProgress => ((currentCycleDay - 1) % cycleDays) / cycleDays;
  double get ovulationCycleProgress => (cycleDays - lutealDays) / cycleDays;

  /// Tipe hari (haid / prediksi haid / masa subur / biasa) untuk tanggal mana pun.
  /// Dipakai oleh Calendar dan strip mingguan di Home.
  CalendarDayType dayTypeFor(DateTime date) {
    final d = _normalize(date);

    if (loggedPeriodDates.contains(d)) return CalendarDayType.period;

    final baseStart = lastPeriodStartDate;
    if (baseStart == null) return CalendarDayType.none;

    final diffDays = d.difference(baseStart).inDays;
    if (diffDays <= 0) return CalendarDayType.none;

    final cycleOffset = diffDays % cycleDays;
    final ovulationOffset = cycleDays - lutealDays;

    // Rentang Prediksi Haid
    if (cycleOffset < periodDays) {
      return diffDays >= cycleDays
          ? CalendarDayType.predictPeriod
          : CalendarDayType.none;
    }

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

    return diffDays % cycleDays == (cycleDays - lutealDays);
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
