import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/login_screen.dart';
import '../../features/lunary_ai/screens/lunary_ai_screen.dart';
import '../services/cycle_settings.dart';
import '../services/cloud_sync.dart';
import '../services/tracker_store.dart';

enum AppNavTab {
  cycle,
  calendar,
  lunaryAi,
  insights,
  profile,
}

// Global auth status
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LunaryAiScreen()),
        );
      });
      break;
  }
}

// Feature protection helper
void checkAuthAndExecute(BuildContext context, {required VoidCallback onSuccess}) {
  if (isUserLoggedIn) {
    onSuccess();
  } else {
    showLoginRequiredDialog(context);
  }
}

Future<bool> showSurveyIfNeeded(BuildContext context, String email) async {
  // 1. Data di cloud menang
  final pull = await CloudSync.pullAll(email);

  // 2. Belum ada data di cloud: pindahkan data tamu ke akun ini seperti biasa
  if (pull == CloudPull.none) {
    final adopted = await CycleSettings.adoptGuestDataInto(email);
    if (adopted) {
      await TrackerStore.adoptGuestData(email);
    }
  }

  await CycleSettings.loadFor(email);
  if (!context.mounted) return false;
  context.read<CycleProvider>().reloadFromSettings();

  // 3. Akun baru di cloud: unggah data lokal sekarang
  if (pull == CloudPull.none) {
    await CloudSync.pushAll(email);
  }

  // Survei tidak ditampilkan lagi setelah login
  return false;
}

// Login / Register prompt pop-up
void showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Limited Access',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: const Text(
        'This feature requires an account so your health data can be safely stored in the cloud.',
        style: TextStyle(fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogContext); // Close the dialog first

            // Open LoginScreen and wait for the login result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );

            // If the user logged in successfully
            if (result != null && result is Map<String, dynamic>) {
              isUserLoggedIn = true;
              globalUserData = {
                'name': result['name'] ?? 'Lunary User',
                'email': result['email'] ?? 'user@lunary.com',
              };

              if (!context.mounted) return;

              // Survei siklus (sekali per akun)
              final surveyShown = await showSurveyIfNeeded(context, globalUserData!['email']!);
              if (!context.mounted) return;

              if (surveyShown) {
                // Setelah survei (diisi / dilewati) langsung ke beranda
                handleAppNavTap(context, AppNavTab.cycle);
              } else {
                // Open the Profile page to show the latest login status
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
