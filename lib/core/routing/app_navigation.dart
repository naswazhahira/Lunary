import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import 'package:flutter/material.dart';
import '../../features/survey/screens/cycle_survey_screen.dart';
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

/// Dipakai setelah login/register dari Profile atau dialog "Limited Access".
/// Memuat data akun, dan kalau akun ini belum pernah survei, membuka survei.
/// Return true kalau survei baru saja ditampilkan (diisi atau dilewati).
Future<bool> showSurveyIfNeeded(BuildContext context, String email) async {
  final needsSurvey = await prepareAccountAfterLogin(context, email);
  if (!needsSurvey || !context.mounted) return false;

  // onFinished dikosongkan: survei akan menutup dirinya sendiri (pop)
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CycleSurveyScreen()),
  );
  return true;
}

/// Dipakai setelah login/register.
/// Memuat data akun (cloud + lokal), lalu mengembalikan true kalau
/// akun ini belum pernah menyelesaikan survei (artinya perlu tampil survei).
Future<bool> prepareAccountAfterLogin(BuildContext context, String email) async {
  // 1. Data di cloud menang
  final pull = await CloudSync.pullAll(email);

  // 2. Belum ada data di cloud: pindahkan data tamu (kalau ada)
  if (pull == CloudPull.none) {
    final adopted = await CycleSettings.adoptGuestDataInto(email);
    if (adopted) {
      await TrackerStore.adoptGuestData(email);
    }
  }

  await CycleSettings.loadFor(email);
  if (!context.mounted) return false;
  context.read<CycleProvider>().reloadFromSettings();

  // 3. Akun baru di cloud: unggah data lokal
  if (pull == CloudPull.none) {
    await CloudSync.pushAll(email);
  }

  // 4. Perlu survei kalau akun ini belum pernah menyelesaikannya
  final done = await CycleSettings.isSurveyDone(email);
  return !done;
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
              final surveyShown =
              await showSurveyIfNeeded(context, globalUserData!['email']!);
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

/// Layar perantara setelah logout: langsung membuka Login, lalu
/// register/akun baru -> Survei -> Home, login akun lama -> Home.
/// Kalau user menekan back di Login, Login dibuka lagi.
class LoginGateScreen extends StatefulWidget {
  const LoginGateScreen({super.key});

  @override
  State<LoginGateScreen> createState() => _LoginGateScreenState();
}

class _LoginGateScreenState extends State<LoginGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    // 1. Buka Login sampai user benar-benar berhasil masuk
    dynamic result;
    while (result is! Map) {
      if (!mounted) return;
      result = await Navigator.of(context).push<dynamic>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
    if (!mounted) return;

    final name = (result['name'] ?? 'Lunary User').toString();
    final email = (result['email'] ?? '').toString();

    isUserLoggedIn = true;
    globalUserData = {'name': name, 'email': email};

    // 2. Muat data akun, lalu cek perlu survei atau tidak
    final needsSurvey =
    email.isEmpty ? false : await prepareAccountAfterLogin(context, email);
    if (!mounted) return;

    if (needsSurvey) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (routeContext) => CycleSurveyScreen(
            onFinished: () {
              Navigator.of(routeContext).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFEEEBFF),
      body: SizedBox.expand(),
    );
  }
}