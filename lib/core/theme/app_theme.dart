import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
