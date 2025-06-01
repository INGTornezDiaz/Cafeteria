import 'package:flutter/material.dart';
import 'app_3d_theme.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF7F11);
  static const Color secondaryColor = Color(0xFFFFD700);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: App3DTheme.primaryColor,
      scaffoldBackgroundColor: App3DTheme.backgroundColor,
      cardColor: App3DTheme.surfaceColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge: App3DTheme.titleStyle,
        titleMedium: App3DTheme.subtitleStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: App3DTheme.primaryButtonStyle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: App3DTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: App3DTheme.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: App3DTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: App3DTheme.titleStyle,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: App3DTheme.surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: App3DTheme.surfaceColor,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: App3DTheme.surfaceColor,
        selectedItemColor: App3DTheme.primaryColor,
        unselectedItemColor: Colors.white70,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: App3DTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
