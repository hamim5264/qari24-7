import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
    ),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        color: AppColors.textSecondaryLight,
      ),
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        color: AppColors.textSecondaryDark,
      ),
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'PlayfairDisplay',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
    ),
  );
}
