import 'package:flutter/material.dart';

class AppTheme {
  // Deposusu Blue Color
  static const Color deposusuBlue = Color(0xFF1A73E8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: deposusuBlue,
      scaffoldBackgroundColor: Colors.grey[50],
      colorScheme: ColorScheme.light(
        primary: deposusuBlue,
        secondary: deposusuBlue.withValues(alpha: 0.8),
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: deposusuBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deposusuBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
