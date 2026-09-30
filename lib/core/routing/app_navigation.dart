import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/login_screen.dart';

enum AppNavTab {
  cycle,
  calendar,
  lunaryAi,
  insights,
  profile,
}

// Status Auth Global
bool isUserLoggedIn = false;
Map<String, String>? globalUserData;

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

    case AppNavTab.insights:
      checkAuthAndExecute(context, onSuccess: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InsightsScreen()),
        );
      });
      break;

    case AppNavTab.profile:
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfileScreen(userData: globalUserData),
        ),
      );
      break;

    case AppNavTab.lunaryAi:
      checkAuthAndExecute(context, onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
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
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Akses Terbatas',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: const Text(
        'Fitur ini membutuhkan akun agar data kesehatan Anda dapat tersimpan dengan aman di cloud.',
        style: TextStyle(fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Nanti Saja', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogContext); // Tutup dialog terlebih dahulu

            // Buka LoginScreen dan tunggu hasil login
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );

            // Jika user berhasil login
            if (result != null && result is Map<String, dynamic>) {
              isUserLoggedIn = true;
              globalUserData = {
                'name': result['name'] ?? 'Pengguna Lunary',
                'email': result['email'] ?? 'user@lunary.com',
              };

              // Buka halaman Profile untuk menampilkan status login terbaru
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userData: globalUserData),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'Login / Register',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
