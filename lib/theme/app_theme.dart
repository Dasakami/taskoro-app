import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Цвета приложения
class AppColors {
  // Основные цвета
  static const Color background = Color(0xFF0A0A13);
  static const Color backgroundSecondary = Color(0xFF12122A);
  static const Color surfaceColor = Color(0xFF1E1E2C);
  static const Color cardBackground = Color(0xFF2A2A3E);
  
  // Текст
  static const Color textPrimary = Color(0xFFE0E0FF);
  static const Color textSecondary = Color(0xFFB3B3D9);
  static const Color textTertiary = Color(0xFF8888AA);
  
  // Акценты и состояния
  static const Color accentPrimary = Color(0xFF6633FF);
  static const Color accentSecondary = Color(0xFFFF3366);
  static const Color accentTertiary = Color(0xFF33FFCC);
  static const Color accentWarn = Color(0xFFFFCC33);
  
  // Статусы
  static const Color success = Color(0xFF33FF99);
  static const Color warning = Color(0xFFFFCC33);
  static const Color error = Color(0xFFFF3333);
  static const Color info = Color(0xFF33CCFF);
  
  // Границы
  static const Color border = Color(0xFF333366);
  static const Color borderLight = Color(0xFF444477);
  
  // Градиенты
  static const List<Color> gradientPrimary = [Color(0xFF6633FF), Color(0xFF33CCFF)];
  static const List<Color> gradientSecondary = [Color(0xFFFF3366), Color(0xFFFF33CC)];
  static const List<Color> gradientAccent = [Color(0xFF33FFCC), Color(0xFF6633FF)];
  static const List<Color> gradientSuccess = [Color(0xFF33FF99), Color(0xFF00DD77)];
}

/// Размеры и отступы
class AppSizes {
  // Отступы
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  
  // Радиусы скругления
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 24.0;
  
  // Размеры шрифтов
  static const double fontSmall = 12.0;
  static const double fontNormal = 14.0;
  static const double fontMedium = 16.0;
  static const double fontLarge = 18.0;
  static const double fontExtraLarge = 24.0;
  static const double fontHuge = 32.0;
}

/// Основная тема приложения
class AppTheme {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    
    // Цветовая схема
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentPrimary,
      secondary: AppColors.accentSecondary,
      tertiary: AppColors.accentTertiary,
      background: AppColors.background,
      surface: AppColors.backgroundSecondary,
      error: AppColors.error,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    
    // Типография
    textTheme: _buildTextTheme(),
    
    // Карточки
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: const BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: AppSizes.md),
    ),
    
    // Кнопки
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 4.0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl,
          vertical: AppSizes.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        textStyle: GoogleFonts.orbitron(
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontNormal,
          letterSpacing: 1.0,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentPrimary,
        side: const BorderSide(
          color: AppColors.accentPrimary,
          width: 2.0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl,
          vertical: AppSizes.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
      ),
    ),
    
    // Поля ввода
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.backgroundSecondary,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.accentPrimary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2.0,
        ),
      ),
      hintStyle: TextStyle(
        color: AppColors.textTertiary,
        fontSize: AppSizes.fontNormal,
      ),
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: AppSizes.fontNormal,
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: AppSizes.fontSmall,
      ),
    ),
    
    // Таб-бар
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.accentPrimary,
      unselectedLabelColor: AppColors.textSecondary,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.accentPrimary,
            width: 2.0,
          ),
        ),
      ),
      labelStyle: GoogleFonts.orbitron(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.fontNormal,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: AppSizes.fontNormal,
      ),
    ),
    
    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 4.0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        fontWeight: FontWeight.w700,
        fontSize: AppSizes.fontLarge,
        letterSpacing: 1.5,
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.radiusMedium),
        ),
        side: const BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
    ),
    
    // Диалоги
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardBackground,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        side: const BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      titleTextStyle: GoogleFonts.orbitron(
        fontWeight: FontWeight.w700,
        fontSize: AppSizes.fontLarge,
        letterSpacing: 1.0,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: TextStyle(
        fontSize: AppSizes.fontNormal,
        color: AppColors.textSecondary,
      ),
    ),
    
    // Drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.cardBackground,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppSizes.radiusLarge),
          bottomRight: Radius.circular(AppSizes.radiusLarge),
        ),
        side: const BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
    ),
    
    // Bottomsheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.cardBackground,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
    ),
    
    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accentPrimary,
      linearTrackColor: AppColors.backgroundSecondary,
    ),
  );
  
  static TextTheme _buildTextTheme() {
    return GoogleFonts.rajdhaniTextTheme(
      ThemeData.dark().textTheme.copyWith(
        // Display styles
        displayLarge: GoogleFonts.orbitron(
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.fontHuge,
          letterSpacing: 2.0,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontWeight: FontWeight.w700,
          fontSize: 24.0,
          letterSpacing: 1.5,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontWeight: FontWeight.w600,
          fontSize: 20.0,
          letterSpacing: 1.0,
          color: AppColors.textPrimary,
        ),
        // Headline styles
        headlineLarge: GoogleFonts.orbitron(
          fontWeight: FontWeight.w700,
          fontSize: 18.0,
          letterSpacing: 1.0,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
          letterSpacing: 0.8,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        // Title styles
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontLarge,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontMedium,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontNormal,
          color: AppColors.textPrimary,
        ),
        // Body styles
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: AppSizes.fontMedium,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.fontNormal,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.fontSmall,
          color: AppColors.textTertiary,
        ),
        // Label styles
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontNormal,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: AppSizes.fontSmall,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 10.0,
          letterSpacing: 0.3,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
