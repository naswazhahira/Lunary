import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const LunaryApp());
}

class LunaryApp extends StatelessWidget {
  const LunaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F3EE),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}