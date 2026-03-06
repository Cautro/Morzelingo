import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color accent = Color(0xFF3B82F6);
  static const Color background = Color(0xFFF1F5F9);
  static const Color card = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color Darkprimary = Color(0xFF3B82F6);
  static const Color DarkprimaryDark = Color(0xFF1D4ED8);
  static const Color Darkaccent = Color(0xFF60A5FA);
  static const Color Darkbackground = Color(0xFF0F172A);
  static const Color Darkcard = Color(0xFF1E293B);
  static const Color Darkerror = Color(0xFFF87171);
  static const Color Darksuccess = Color(0xFF4ADE80);
  static const Color Darkwarning = Color(0xFFFBBF24);
  static const Color Darkinfo = Color(0xFF38BDF8);
  static const Color DarktextPrimary = Color(0xFFF1F5F9);
  static const Color DarktextSecondary = Color(0xFF94A3B8);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,

    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: card,
    ),

    cardTheme: CardThemeData(
      color: card,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary, width: 2),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Darkbackground,

    colorScheme: const ColorScheme.dark(
      primary: Darkprimary,
      secondary: Darkaccent,
      surface: Darkcard,
      error: Darkerror,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DarktextPrimary,
    ),

    cardTheme: CardThemeData(
      color: Darkcard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Darkprimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Darkcard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: DarktextSecondary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: DarktextSecondary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Darkprimary, width: 2),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: DarktextPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: DarktextSecondary,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: DarktextPrimary,
      ),
    ),
  );

}