import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Main colors
  static const Color cardBackground = Color(0xFF1E1E2C); // Пример красивого тёмного цвета
  static const background = Color(0xFF0A0A13);
  static const backgroundSecondary = Color(0xFF12122A);
  static const textPrimary = Color(0xFFE0E0FF);
  static const textSecondary = Color(0xFFB3B3D9);
  static const accentPrimary = Color(0xFF6633FF);
  static const accentSecondary = Color(0xFFFF3366);
  static const accentTertiary = Color(0xFF33FFCC);
  static const success = Color(0xFF33FF99);
  static const warning = Color(0xFFFFCC33);
  static const error = Color(0xFFFF3333);
  static const border = Color(0xFF333366);

  // Gradients
  static const gradientPrimary = [Color(0xFF6633FF), Color(0xFF33CCFF)];
  static const gradientSecondary = [Color(0xFFFF3366), Color(0xFFFF33CC)];
  static const gradientAccent = [Color(0xFF33FFCC), Color(0xFF6633FF)];
}

class AppTheme {

  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentPrimary,
      secondary: AppColors.accentSecondary,
      tertiary: AppColors.accentTertiary,
      background: AppColors.background,
      surface: AppColors.backgroundSecondary,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.rajdhaniTextTheme(
      ThemeData.dark().textTheme.copyWith(
        displayLarge: GoogleFonts.orbitron(
          textStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: 2,
          ),
        ),
        displayMedium: GoogleFonts.orbitron(
          textStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        displaySmall: GoogleFonts.orbitron(
          textStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        bodyLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.backgroundSecondary,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.textPrimary,
        textStyle: GoogleFonts.orbitron(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            fontSize: 14,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentPrimary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
  );
}