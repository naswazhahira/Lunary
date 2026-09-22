import 'package:flutter/material.dart';

/// color palette Lunary app.
class AppColors {
  AppColors._();

  // ---- Brand -----------------------------------------------------------
  static const Color primaryPink = Color(0xFFED5589);
  static const Color primaryPurple = Color(0xFF6C5CE7);

  // ---- Text --------------------------------------------------------------
  static const Color darkText = Color(0xFF2E2A4A);
  static const Color subText = Color(0xFF8E82A3);
  static const Color darkerSubText = Color(0xFF6E6A8A);

  // ---- Background gradient (Home, Calendar, etc.) -----------------------
  static const LinearGradient homeBackgroundGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFE2DCF7),
      Color(0xFFEFE8F9),
      Color(0xFFF9E9EE),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  // ---- Cards ---------------------------------------------------------
  static Color cardBackground = Colors.white.withOpacity(0.9);
  static Color cardShadow = Colors.black.withOpacity(0.03);
  static const double cardRadius = 24;

  // ---- Calendar specific ----------------------------------------------
  static const Color period = primaryPink;
  static const Color predictPeriod = Color(0xFFF5A9C6);
  static const Color fertile = primaryPurple;
  static const Color ovulation = Color(0xFF4B3F8C);
  static const Color calendarNumber = darkText;
  static const Color cycleStatusCircle = Color(0xFFC9BFF0);
  static const Color cycleStatusIconBg = Color(0xFFD8D0FA);
  static const Color cycleStatusIconColor = Color(0xFF6B6560);

  // ---- Bottom nav ---------------------------------------------------
  static const Color navActive = primaryPurple;
  static const Color navInactive = subText;
}
