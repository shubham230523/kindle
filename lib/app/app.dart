import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/splash/screens/splash_screen.dart';

class KindleApp extends StatelessWidget {
  const KindleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kindle',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
