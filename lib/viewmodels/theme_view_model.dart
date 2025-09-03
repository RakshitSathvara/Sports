import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/shared_preferences_manager.dart';

class ThemeViewModel with ChangeNotifier {
  final SharedPreferencesManager _prefs = SharedPreferencesManager();
  static const String _themeModeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeViewModel() {
    _loadTheme();
  }

  void _loadTheme() async {
    final themeModeString = await _prefs.getString(_themeModeKey);
    if (themeModeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    await _prefs.setString(_themeModeKey, themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
