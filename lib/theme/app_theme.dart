import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color lightRed = Color(0xFFFF6659);
  static const Color textDark = Color(0xFF2E2E2E);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryRed,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      elevation: 2,
      iconTheme: IconThemeData(color: primaryRed),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryRed.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryRed),
      ),
      filled: true,
      fillColor: white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}
