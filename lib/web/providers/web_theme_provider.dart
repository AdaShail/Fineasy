import 'package:flutter/material.dart';
import '../../core/theme/responsive_theme_data.dart';
import '../../services/theme_manager_service.dart';

/// Provider for managing web theme state
class WebThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;
  Color _accentColor = Colors.orange;
  double _currentWidth = 1024;
  
  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  Color get accentColor => _accentColor;
  
  /// Get light theme with current settings
  ThemeData get lightTheme => ResponsiveThemeData.getLightTheme(
    _seedColor,
    _currentWidth,
    accentColor: _accentColor,
  );
  
  /// Get dark theme with current settings
  ThemeData get darkTheme => ResponsiveThemeData.getDarkTheme(
    _seedColor,
    _currentWidth,
    accentColor: _accentColor,
  );
  
  /// Initialize theme from storage
  Future<void> initialize() async {
    _themeMode = await ThemeManagerService.getThemeMode();
    _seedColor = await ThemeManagerService.getPrimaryColor();
    _accentColor = await ThemeManagerService.getAccentColor();
    notifyListeners();
  }
  
  /// Update screen width for responsive theme
  void updateScreenWidth(double width) {
    if (_currentWidth != width) {
      _currentWidth = width;
      notifyListeners();
    }
  }
  
  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await ThemeManagerService.setThemeMode(mode);
    notifyListeners();
  }
  
  /// Set seed color
  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    await ThemeManagerService.setPrimaryColor(color);
    notifyListeners();
  }
  
  /// Set accent color
  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    await ThemeManagerService.setAccentColor(color);
    notifyListeners();
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.system);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
  
  /// Reset to default theme
  Future<void> resetToDefault() async {
    await ThemeManagerService.resetToDefault();
    _themeMode = ThemeMode.system;
    _seedColor = Colors.blue;
    _accentColor = Colors.orange;
    notifyListeners();
  }
  
  /// Check if current theme is dark
  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}
