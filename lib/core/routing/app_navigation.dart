import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

enum AppNavTab {
  cycle,
  calendar,
  lunaryAi,
  insights,
  profile,
}

// Simulasi status auth
bool isUserLoggedIn = false;

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

    case AppNavTab.profile:
    // Menggunakan pushReplacement jika ProfileScreen memiliki AppBottomNavBar,
    // atau push jika ProfileScreen adalah sub-layar terpisah.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      break;

    case AppNavTab.lunaryAi:
    case AppNavTab.insights:
      checkAuthAndExecute(context, onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feature coming soon!')),
        );
      });
      break;
  }
}

// Helper proteksi fitur
void checkAuthAndExecute(BuildContext context, {required VoidCallback onSuccess}) {
  if (isUserLoggedIn) {
    onSuccess();
  } else {
    showLoginRequiredDialog(context);
  }
}

// Pop-up Ajakan Login / Registrasi
void showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Login Required',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: const Text(
        'This feature requires an account so your data can be safely backed up to the cloud.',
        style: TextStyle(fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not Now', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigating to Login Screen')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB197FC),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Login / Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}