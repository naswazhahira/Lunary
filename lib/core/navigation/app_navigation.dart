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

// Simulasi status auth (bisa diintegrasikan dengan Provider/Riverpod/Bloc)
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
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      break;

    case AppNavTab.lunaryAi:
    case AppNavTab.insights:
    // Proteksi fitur berbasis Auth
      checkAuthAndExecute(context, onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur dapat diakses!')),
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
        'Login Diperlukan',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: const Text(
        'Fitur ini membutuhkan akun agar data kamu tersimpan secara aman di cloud.',
        style: TextStyle(fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Nanti Saja', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Pindah ke Halaman Login/Registrasi terpisah milikmu
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigasi ke Login Screen')),
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
