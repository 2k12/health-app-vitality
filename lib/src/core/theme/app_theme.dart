import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // Backward Compatibility
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.accent;
  static const Color cardColor = AppColors.surfaceLight; // Or a safe default
  static const Color scaffoldBackgroundColor = AppColors.backgroundLight;
  static const Color errorColor = AppColors.error;
  static const Color surfaceColor = AppColors.surfaceLight;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black, // Better contrast on mint
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _lightTextTheme,
      elevatedButtonTheme: _elevatedButtonTheme(isLight: true),
      inputDecorationTheme: _inputDecorationTheme(isLight: true),
      cardTheme: _cardTheme(isLight: true),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.accent,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _darkTextTheme,
      elevatedButtonTheme: _elevatedButtonTheme(isLight: false),
      inputDecorationTheme: _inputDecorationTheme(isLight: false),
      cardTheme: _cardTheme(isLight: false),
    );
  }

  static TextTheme get _lightTextTheme => TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.textPrimaryLight),
        displayMedium: AppTextStyles.displayMedium
            .copyWith(color: AppColors.textPrimaryLight),
        headlineLarge: AppTextStyles.headingLarge
            .copyWith(color: AppColors.textPrimaryLight),
        headlineMedium: AppTextStyles.headingMedium
            .copyWith(color: AppColors.textPrimaryLight),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textPrimaryLight),
        labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
      );

  static TextTheme get _darkTextTheme => TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.displayMedium
            .copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: AppTextStyles.headingLarge
            .copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: AppTextStyles.headingMedium
            .copyWith(color: AppColors.textPrimaryDark),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme({required bool isLight}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isLight ? AppColors.primary : AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: (isLight ? AppColors.primary : AppColors.primaryDark)
            .withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({required bool isLight}) {
    final fillColor =
        isLight ? const Color(0xFFF5F5F5) : const Color(0xFF2C2C2C);

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: isLight ? AppColors.primary : AppColors.primaryDark,
            width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: TextStyle(
        color: isLight
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryDark,
      ),
    );
  }

  static CardTheme _cardTheme({required bool isLight}) {
    return CardTheme(
      color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    );
  }
}
