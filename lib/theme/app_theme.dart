import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Black theme colors
  static const Color primaryColor = Color(0xFFE50914); // Netflix red
  static const Color backgroundColor = Color(0xFF000000); // Pure black
  static const Color surfaceColor = Color(0xFF1A1A1A); // Dark gray
  static const Color cardColor = Color(0xFF2A2A2A); // Slightly lighter gray
  static const Color textPrimaryColor = Color(0xFFFFFFFF); // White
  static const Color textSecondaryColor = Color(0xFFCCCCCC); // Light gray
  static const Color textTertiaryColor = Color(0xFF999999); // Medium gray

  // Simple theme without heavy styling
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false, // Disable Material 3 for better performance
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact, // Compact for better performance

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimaryColor),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2, // Minimal elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimaryColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      iconTheme: const IconThemeData(
        color: textSecondaryColor,
        size: 20, // Smaller icons for better performance
      ),

      dividerTheme: const DividerThemeData(
        color: surfaceColor,
        thickness: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textTertiaryColor),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 2,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceColor,
      ),
    );
  }
}
