import 'package:flutter/material.dart';
import '../../discovery/screens/discovery_chat_screen.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DiscoveryChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: Icon(
                      Icons.wb_sunny,
                      color: AppColors.accent,
                      size: isDesktop ? 120 : 80,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              "A spark that starts something",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSplash,
                fontSize: isDesktop ? 24 : 18,
                letterSpacing: 1.2,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
