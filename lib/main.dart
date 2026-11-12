import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/providers/cycle_provider.dart';
import 'core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat tema tersimpan sebelum frame pertama supaya warnanya tidak berkedip.
  final themeController = ThemeController();
  await themeController.load();

  runApp(LunaryApp(themeController: themeController));
}

class LunaryApp extends StatelessWidget {
  final ThemeController themeController;

  const LunaryApp({Key? key, required this.themeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) => MaterialApp.router(
          title: 'Lunary',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFF7F3EE),
            useMaterial3: true,
            // Date picker, time picker, dll. ikut warna tema
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.palette.primaryPurple,
              primary: theme.palette.primaryPurple,
            ),
          ),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
