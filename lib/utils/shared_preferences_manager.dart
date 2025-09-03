
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static final SharedPreferencesManager _instance = SharedPreferencesManager._internal();
  late SharedPreferences _prefs;

  factory SharedPreferencesManager() {
    return _instance;
  }

  SharedPreferencesManager._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Example method to store a string value
  Future<void> setStringValue({String key = '', String value = ''}) async {
    await _prefs.setString(key, value);
  }

  // Example method to retrieve a string value
  String getStringValue(String key, {String defaultValue = ""}) {
    return _prefs.getString(key) ?? defaultValue;
  }
}
