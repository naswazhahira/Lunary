import 'package:shared_preferences/shared_preferences.dart';

/// Pengaturan siklus yang dipakai bersama oleh halaman survei,
/// Profile > Cycle and ovulation, dan CycleProvider.
/// Disimpan per akun (kunci = email) di shared_preferences.
/// Sebelum login, dipakai akun khusus [guestId].
class CycleSettings {
  CycleSettings._();

  static const String guestId = 'guest';

  // null = belum diisi
  static int? cycleLength;
  static int? periodLength;
  static int? lutealPhase;
  static bool showPregnancyChance = true;
  static bool showCycleDays = false;

  /// True kalau pengguna memilih "My cycle is irregular" di survei.
  static bool irregularCycle = false;

  /// Tanggal haid yang pernah dicatat (dimuat dari penyimpanan akun aktif).
  static Set<DateTime> loggedDates = {};

  static String? _email;

  static String _key(String email, String field) => 'cycle_${email.toLowerCase()}_$field';

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Set<DateTime> _parseDates(List<String>? list) {
    final result = <DateTime>{};
    if (list == null) return result;
    for (final s in list) {
      final p = s.split('-');
      if (p.length != 3) continue;
      final y = int.tryParse(p[0]);
      final m = int.tryParse(p[1]);
      final d = int.tryParse(p[2]);
      if (y == null || m == null || d == null) continue;
      result.add(DateTime(y, m, d));
    }
    return result;
  }

  /// Muat pengaturan milik akun [email] ke memori (dipanggil saat login).
  static Future<void> loadFor(String email) async {
    final prefs = await SharedPreferences.getInstance();
    _email = email;
    cycleLength = prefs.getInt(_key(email, 'cycleLength'));
    periodLength = prefs.getInt(_key(email, 'periodLength'));
    lutealPhase = prefs.getInt(_key(email, 'lutealPhase'));
    showPregnancyChance = prefs.getBool(_key(email, 'showPregnancyChance')) ?? true;
    showCycleDays = prefs.getBool(_key(email, 'showCycleDays')) ?? false;
    irregularCycle = prefs.getBool(_key(email, 'irregularCycle')) ?? false;
    loggedDates = _parseDates(prefs.getStringList(_key(email, 'periodDates')));
  }

  /// Muat pengaturan untuk pengguna yang belum login (guest).
  static Future<void> loadGuest() => loadFor(guestId);

  /// Kalau survei guest sudah diisi dan akun [email] belum pernah survei,
  /// salin jawaban guest (dan tanggal haid) ke akun itu dan tandai survei akun selesai.
  /// Panggil SEBELUM loadFor(email).
  static Future<void> adoptGuestDataInto(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final accountDone = prefs.getBool(_key(email, 'surveyDone')) ?? false;
    final guestDone = prefs.getBool(_key(guestId, 'surveyDone')) ?? false;
    if (accountDone || !guestDone) return;

    for (final f in ['cycleLength', 'periodLength', 'lutealPhase']) {
      final v = prefs.getInt(_key(guestId, f));
      if (v != null) await prefs.setInt(_key(email, f), v);
    }

    final guestIrregular = prefs.getBool(_key(guestId, 'irregularCycle'));
    if (guestIrregular != null) {
      await prefs.setBool(_key(email, 'irregularCycle'), guestIrregular);
    }

    final accountDates = prefs.getStringList(_key(email, 'periodDates'));
    final guestDates = prefs.getStringList(_key(guestId, 'periodDates'));
    if ((accountDates == null || accountDates.isEmpty) &&
        guestDates != null &&
        guestDates.isNotEmpty) {
      await prefs.setStringList(_key(email, 'periodDates'), guestDates);
    }

    await prefs.setBool(_key(email, 'surveyDone'), true);
  }

  static Future<bool> isSurveyDone(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(email, 'surveyDone')) ?? false;
  }

  static Future<void> markSurveyDone() async {
    final email = _email;
    if (email == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(email, 'surveyDone'), true);
  }

  /// Simpan nilai yang ada di memori ke akun yang sedang aktif (login atau guest).
  static Future<void> save() async {
    final email = _email;
    if (email == null) return;
    final prefs = await SharedPreferences.getInstance();

    Future<void> putInt(String field, int? value) async {
      if (value == null) {
        await prefs.remove(_key(email, field));
      } else {
        await prefs.setInt(_key(email, field), value);
      }
    }

    await putInt('cycleLength', cycleLength);
    await putInt('periodLength', periodLength);
    await putInt('lutealPhase', lutealPhase);
    await prefs.setBool(_key(email, 'showPregnancyChance'), showPregnancyChance);
    await prefs.setBool(_key(email, 'showCycleDays'), showCycleDays);
    await prefs.setBool(_key(email, 'irregularCycle'), irregularCycle);
  }

  /// Simpan seluruh tanggal haid ke akun yang sedang aktif.
  static Future<void> saveLoggedDates(Iterable<DateTime> dates) async {
    final email = _email;
    if (email == null) return;

    final normalized = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    loggedDates = normalized;
    final list = normalized.map(_fmt).toList()..sort();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key(email, 'periodDates'), list);
  }

  /// Kosongkan memori (dipanggil saat logout). Data di penyimpanan tetap ada.
  /// Setelah ini panggil [loadGuest] supaya pengaturan guest aktif kembali.
  static void unload() {
    cycleLength = null;
    periodLength = null;
    lutealPhase = null;
    showPregnancyChance = true;
    showCycleDays = false;
    irregularCycle = false;
    loggedDates = {};
    _email = null;
  }

  /// Hapus semua pengaturan akun ini (dipanggil saat hapus akun).
  static Future<void> deleteAccountData() async {
    final email = _email;
    if (email != null) {
      final prefs = await SharedPreferences.getInstance();
      for (final f in [
        'cycleLength',
        'periodLength',
        'lutealPhase',
        'showPregnancyChance',
        'showCycleDays',
        'irregularCycle',
        'periodDates',
        'surveyDone',
      ]) {
        await prefs.remove(_key(email, f));
      }
    }
    unload();
  }
}
