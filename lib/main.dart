import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const KindleApp());
}

class KindleApp extends StatelessWidget {
  const KindleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kindle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
