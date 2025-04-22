import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false; // Default to light mode
    notifyListeners();
  }
  
  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
    
    notifyListeners();
  }
}