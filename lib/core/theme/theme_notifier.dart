import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier() {
    _load();
  }

  ThemeMode _mode = ThemeMode.system;
  bool _useOledDark = true;

  ThemeMode get mode => _mode;
  bool get useOledDark => _useOledDark;

  void setMode(ThemeMode mode, {bool? useOledDark}) {
    _mode = mode;
    if (useOledDark != null) {
      _useOledDark = useOledDark;
    }
    _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_modeKey);
    final storedOled = prefs.getBool(_oledKey);
    if (storedMode != null) {
      switch (storedMode) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        default:
          _mode = ThemeMode.system;
      }
    }
    if (storedOled != null) {
      _useOledDark = storedOled;
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _mode.name);
    await prefs.setBool(_oledKey, _useOledDark);
  }

  static const String _modeKey = 'theme_mode';
  static const String _oledKey = 'theme_oled';
}
