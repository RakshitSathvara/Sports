import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider._internal();
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;

  static const String _themeKey = 'theme_mode';

  ThemeType _themeType = ThemeType.system;

  ThemeType get themeType => _themeType;

  ThemeMode get themeMode {
    switch (_themeType) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
      case ThemeType.system:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode {
    if (_themeType == ThemeType.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeType == ThemeType.dark;
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeType.system.index;
    _themeType = ThemeType.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(ThemeType themeType) async {
    _themeType = themeType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeType.index);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeType == ThemeType.light) {
      await setTheme(ThemeType.dark);
    } else if (_themeType == ThemeType.dark) {
      await setTheme(ThemeType.light);
    } else {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      await setTheme(brightness == Brightness.dark ? ThemeType.light : ThemeType.dark);
    }
  }
}
