import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -----------------------------------------------------------------------------
// Palet tema
// -----------------------------------------------------------------------------

/// Satu set warna lengkap untuk satu tema.
class AppPalette {
  final String id;
  final String name;
  final String subtitle;

  /// Aksen 1: warna haid, tombol utama, badge.
  final Color primaryPink;

  /// Aksen 2: navigasi aktif, masa subur, tautan.
  final Color primaryPurple;

  final Color predictPeriod;
  final Color ovulation;
  final Color cycleRingTrack;
  final Color avatar;
  final Color softTint;
  final Color ringFertile;
  final Color ringLuteal;

  /// Tiga warna latar gradien (kiri ke kanan).
  final List<Color> gradient;

  const AppPalette({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.primaryPink,
    required this.primaryPurple,
    required this.predictPeriod,
    required this.ovulation,
    required this.cycleRingTrack,
    required this.avatar,
    required this.softTint,
    required this.ringFertile,
    required this.ringLuteal,
    required this.gradient,
  });

  /// Pink + ungu (tema asli Lunary).
  static const AppPalette lunary = AppPalette(
    id: 'lunary',
    name: 'Lunary',
    subtitle: 'Pink & Purple',
    primaryPink: Color(0xFFED5589),
    primaryPurple: Color(0xFF6C5CE7),
    predictPeriod: Color(0xFFF5A9C6),
    ovulation: Color(0xFF4B3F8C),
    cycleRingTrack: Color(0xFFEAE1F0),
    avatar: Color(0xFFB197FC),
    softTint: Color(0xFFF3E7FC),
    ringFertile: Color(0xFFF5C77E),
    ringLuteal: Color(0xFFD8CFF0),
    gradient: [Color(0xFFE2DCF7), Color(0xFFEFE8F9), Color(0xFFF9E9EE)],
  );

  /// Merah + oranye.
  static const AppPalette sunset = AppPalette(
    id: 'sunset',
    name: 'Sunset',
    subtitle: 'Red & Orange',
    primaryPink: Color(0xFFE04B55),
    primaryPurple: Color(0xFFE8730C),
    predictPeriod: Color(0xFFF5A8A8),
    ovulation: Color(0xFF9A3412),
    cycleRingTrack: Color(0xFFF3E3D6),
    avatar: Color(0xFFF4A261),
    softTint: Color(0xFFFDEBDD),
    ringFertile: Color(0xFFF6C453),
    ringLuteal: Color(0xFFF4D6C6),
    gradient: [Color(0xFFF9DCC8), Color(0xFFFCEBDD), Color(0xFFFBDDE0)],
  );

  /// Hijau teal + biru.
  static const AppPalette ocean = AppPalette(
    id: 'ocean',
    name: 'Ocean',
    subtitle: 'Blue & Green',
    primaryPink: Color(0xFF14A387),
    primaryPurple: Color(0xFF2F6FED),
    predictPeriod: Color(0xFFA7E3D2),
    ovulation: Color(0xFF1E3A8A),
    cycleRingTrack: Color(0xFFDCEAF2),
    avatar: Color(0xFF7FA8F5),
    softTint: Color(0xFFE3F0FB),
    ringFertile: Color(0xFFF2C94C),
    ringLuteal: Color(0xFFCFE3F5),
    gradient: [Color(0xFFD5E8F7), Color(0xFFE3F1F3), Color(0xFFE0F4EA)],
  );

  static const List<AppPalette> all = [lunary, sunset, ocean];

  static AppPalette byId(String? id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return lunary;
  }
}

// -----------------------------------------------------------------------------
// AppColors: nama-nama lama dipertahankan, tapi warna tema kini mengikuti
// palet yang sedang aktif.
// -----------------------------------------------------------------------------

class AppColors {
  AppColors._();

  static AppPalette _palette = AppPalette.lunary;
  static AppPalette get palette => _palette;

  /// Dipanggil oleh ThemeController. Jangan dipanggil dari layar.
  static void apply(AppPalette palette) => _palette = palette;

  // ---- Berubah mengikuti tema (getter, BUKAN const) -------------------------
  static Color get primaryPink => _palette.primaryPink;
  static Color get primaryPurple => _palette.primaryPurple;

  static Color get period => _palette.primaryPink;
  static Color get predictPeriod => _palette.predictPeriod;
  static Color get fertile => _palette.primaryPurple;
  static Color get ovulation => _palette.ovulation;

  static Color get navActive => _palette.primaryPurple;
  static Color get cycleRingTrack => _palette.cycleRingTrack;

  static Color get avatar => _palette.avatar;
  static Color get softTint => _palette.softTint;
  static Color get ringFertile => _palette.ringFertile;
  static Color get ringLuteal => _palette.ringLuteal;

  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: _palette.gradient,
    stops: const [0.0, 0.6, 1.0],
  );

  // ---- Tetap di semua tema (tetap const) -------------------------------------
  static const Color darkText = Color(0xFF2E2A4A);
  static const Color subText = Color(0xFF8E82A3);
  static const Color darkerSubText = Color(0xFF6E6A8A);

  static Color cardBackground = Colors.white.withOpacity(0.9);
  static Color cardShadow = Colors.black.withOpacity(0.03);
  static const double cardRadius = 24;

  static const Color calendarNumber = darkText;
  static const Color cycleStatusCircle = Color(0xFFC9BFF0);
  static const Color cycleStatusIconBg = Color(0xFFD8D0FA);
  static const Color cycleStatusIconColor = Color(0xFF6B6560);

  static const Color navInactive = subText;
}

// -----------------------------------------------------------------------------
// Pengatur tema (disimpan di perangkat)
// -----------------------------------------------------------------------------

class ThemeController extends ChangeNotifier {
  static const String _prefsKey = 'app_theme_id';

  AppPalette _palette = AppPalette.lunary;
  AppPalette get palette => _palette;

  /// Panggil sekali di main() sebelum runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _palette = AppPalette.byId(prefs.getString(_prefsKey));
    AppColors.apply(_palette);
    notifyListeners();
  }

  Future<void> select(AppPalette palette) async {
    if (palette.id == _palette.id) return;
    _palette = palette;
    AppColors.apply(palette);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, palette.id);
  }
}

extension ThemeWatch on BuildContext {
  /// Panggil di awal build() supaya layar digambar ulang saat tema berganti.
  void watchTheme() {
    watch<ThemeController>();
  }
}
