import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme manager service for managing app themes
class ThemeManagerService {
  static const String _themeKey = 'app_theme_mode';
  static const String _primaryColorKey = 'app_primary_color';
  static const String _accentColorKey = 'app_accent_color';

  /// Available theme modes
  static const List<ThemeMode> themeModes = [
    ThemeMode.light,
    ThemeMode.dark,
    ThemeMode.system,
  ];

  /// Available primary colors
  static const Map<String, Color> primaryColors = {
    'Blue': Colors.blue,
    'Indigo': Colors.indigo,
    'Purple': Colors.purple,
    'Deep Purple': Colors.deepPurple,
    'Teal': Colors.teal,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Red': Colors.red,
    'Pink': Colors.pink,
    'Cyan': Colors.cyan,
  };

  /// Get current theme mode
  static Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);
      
      if (themeModeString == null) return ThemeMode.system;
      
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    } catch (e) {
      return ThemeMode.system;
    }
  }

  /// Set theme mode
  static Future<bool> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      return false;
    }
  }

  /// Get primary color
  static Future<Color> getPrimaryColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_primaryColorKey);
      
      if (colorValue == null) return Colors.blue;
      
      return Color(colorValue);
    } catch (e) {
      return Colors.blue;
    }
  }

  /// Set primary color
  static Future<bool> setPrimaryColor(Color color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_primaryColorKey, color.toARGB32());
    } catch (e) {
      return false;
    }
  }

  /// Get accent color
  static Future<Color> getAccentColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_accentColorKey);
      
      if (colorValue == null) return Colors.orange;
      
      return Color(colorValue);
    } catch (e) {
      return Colors.orange;
    }
  }

  /// Set accent color
  static Future<bool> setAccentColor(Color color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_accentColorKey, color.toARGB32());
    } catch (e) {
      return false;
    }
  }

  /// Reset to default theme
  static Future<bool> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
      await prefs.remove(_primaryColorKey);
      await prefs.remove(_accentColorKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get light theme data
  static ThemeData getLightTheme(Color primaryColor, Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Get dark theme data
  static ThemeData getDarkTheme(Color primaryColor, Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor.withValues(alpha: 0.8),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Get theme mode name
  static String getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get theme mode icon
  static IconData getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
