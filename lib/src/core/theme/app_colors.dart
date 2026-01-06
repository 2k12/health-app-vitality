import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF1A237E); // Deep Indigo
  static const Color primaryDark = Color(0xFF536DFE); // Soft Indigo (Dark Mode)

  // Accent
  static const Color accent = Color(0xFF00E676); // Vibrant Mint
  static const Color secondary = accent; // Alias for secondary

  // Background
  static const Color backgroundLight = Color(0xFFF8F9FA); // Off-White
  static const Color backgroundDark = Color(0xFF121212); // True Black

  // Surface
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark Grey
  static const Color surface =
      surfaceDark; // Alias for surface (defaulting to dark for now)

  // Text
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFEEEEEE);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // Status
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFBC02D);

  // Tint & Background variants
  static const Color indigoTint = Color(0xFFE8EAF6);

  // Chart/Visualizations
  static const Color chartProtein = accent;
  static const Color chartCarbs = Color(0xFF448AFF); // Blue Accent equivalent
  static const Color chartFat = Color(0xFFFFAB40); // Orange Accent equivalent
}
