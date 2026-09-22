import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';

/// Enum untuk daftar tab di Bottom Navigation Bar
enum AppNavTab {
  cycle,
  calendar,
  lunaryAi,
  insights,
  profile,
}

void handleAppNavTap(BuildContext context, AppNavTab tab) {
  switch (tab) {
    case AppNavTab.cycle:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      break;
    case AppNavTab.calendar:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CalendarScreen()),
      );
      break;
    case AppNavTab.lunaryAi:
    case AppNavTab.insights:
    case AppNavTab.profile:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon')),
      );
      break;
  }
}
