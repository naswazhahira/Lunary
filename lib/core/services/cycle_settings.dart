import 'package:shared_preferences/shared_preferences.dart';

/// Pengaturan siklus yang dipakai bersama oleh halaman survei,
/// Profile > Cycle and ovulation, dan CycleProvider.
/// Disimpan per akun (kunci = email) di shared_preferences.
class CycleSettings {
  CycleSettings._();

  // null = belum diisi
  static int? cycleLength;
  static int? periodLength;
  static int? lutealPhase;
  static bool showPregnancyChance = true;
  static bool showCycleDays = false;

  static String? _email;

  static String _key(String email, String field) => 'cycle_${email.toLowerCase()}_$field';

  /// Muat pengaturan milik akun [email] ke memori (dipanggil saat login).
  static Future<void> loadFor(String email) async {
    final prefs = await SharedPreferences.getInstance();
    _email = email;
    cycleLength = prefs.getInt(_key(email, 'cycleLength'));
    periodLength = prefs.getInt(_key(email, 'periodLength'));
    lutealPhase = prefs.getInt(_key(email, 'lutealPhase'));
    showPregnancyChance = prefs.getBool(_key(email, 'showPregnancyChance')) ?? true;
    showCycleDays = prefs.getBool(_key(email, 'showCycleDays')) ?? false;
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

  /// Simpan nilai yang ada di memori ke akun yang sedang login.
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
  }

  /// Kosongkan memori (dipanggil saat logout). Data di penyimpanan tetap ada.
  static void unload() {
    cycleLength = null;
    periodLength = null;
    lutealPhase = null;
    showPregnancyChance = true;
    showCycleDays = false;
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
        'surveyDone',
      ]) {
        await prefs.remove(_key(email, f));
      }
    }
    unload();
  }
}