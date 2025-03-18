import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);

  // Secondary colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF000000);

  // Error colors
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFEF5350);

  // Success colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);

  // Warning colors
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);

  // Info colors
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);

  // Mood scale colors
  static const Color moodDepressionDark = Color(0xFF1A237E);  // Very depressed
  static const Color moodDepressionMedium = Color(0xFF3949AB);  // Depressed
  static const Color moodDepressionLight = Color(0xFF7986CB);  // Mildly depressed
  static const Color moodNeutral = Color(0xFF90CAF9);  // Neutral
  static const Color moodPositiveLight = Color(0xFF80DEEA);  // Mildly positive
  static const Color moodPositiveMedium = Color(0xFF26C6DA);  // Positive
  static const Color moodPositiveHigh = Color(0xFF00ACC1);  // Very positive
  static const Color moodManic = Color(0xFFD81B60);  // Manic

  // Gradient for mood scales
  static const List<Color> moodGradient = [
    moodDepressionDark,
    moodDepressionMedium,
    moodDepressionLight,
    moodNeutral,
    moodPositiveLight,
    moodPositiveMedium,
    moodPositiveHigh,
    moodManic,
  ];

  // Other utility colors
  static const Color divider = Color(0xFFBDBDBD);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color overlay = Color(0x80000000);
}