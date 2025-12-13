import 'package:flutter/material.dart';
import 'package:shiny_counter/core/storage/app_prefs_keys.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier([KeyValueStore? store]) : _store = store ?? SharedPrefsStore() {
    _load();
  }

  ThemeMode _mode = ThemeMode.system;
  bool _useOledDark = true;
  final KeyValueStore _store;

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
    final storedMode = await _store.getString(AppPrefsKeys.themeMode);
    final storedOled = await _store.getBool(AppPrefsKeys.themeOled);
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
    await _store.setString(AppPrefsKeys.themeMode, _mode.name);
    await _store.setBool(AppPrefsKeys.themeOled, _useOledDark);
  }
}
