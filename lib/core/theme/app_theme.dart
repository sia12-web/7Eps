import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Indie Bookstore meets High-End Journal
  static const Color sageGreen = Color(0xFF87A878);
  static const Color terracotta = Color(0xFFC17F59);
  static const Color cream = Color(0xFFF5F1E8);
  static const Color charcoal = Color(0xFF3D3D3D);
  static const Color softBrown = Color(0xFF8B7355);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: sageGreen,
        primary: sageGreen,
        secondary: terracotta,
        surface: cream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: charcoal,
      ),
      scaffoldBackgroundColor: cream,

      // Typography
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: charcoal,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: charcoal,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: charcoal,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: sageGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: sageGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: sageGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: charcoal.withOpacity(0.5),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: charcoal.withOpacity(0.1),
        thickness: 1,
      ),
    );
  }
}
