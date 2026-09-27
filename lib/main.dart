import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/providers/cycle_provider.dart';

void main() {
  runApp(const LunaryApp());
}

class LunaryApp extends StatelessWidget {
  const LunaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CycleProvider(),
      child: MaterialApp.router(
        title: 'Lunary',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF7F3EE),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
