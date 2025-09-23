import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider._internal();
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;

  static const String _themeKey = 'theme_mode';
  bool _disposed = false;

  ThemeType _themeType = ThemeType.dark;

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
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeType.dark.index;
    _themeType = ThemeType.values[themeIndex];
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  Future<void> setTheme(ThemeType themeType) async {
    _themeType = themeType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeType.index);
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
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

  @override
  void addListener(VoidCallback listener) {
    // If disposed and trying to add a listener, reset the disposed state
    // This handles the case where the singleton provider is reused after disposal
    if (_disposed) {
      _disposed = false;
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    // Only remove listener if not disposed
    if (!_disposed) {
      super.removeListener(listener);
    }
  }

  @override
  // ignore: must_call_super
  void dispose() {
    // For singleton pattern, don't actually dispose the notifier
    // Just mark as disposed to prevent notifications
    _disposed = true;
    // Don't call super.dispose() to keep the singleton alive
  }
}
