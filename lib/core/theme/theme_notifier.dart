import 'package:flutter/material.dart';
import 'package:shiny_counter/core/storage/app_prefs_keys.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier([KeyValueStore? store]) : _store = store ?? SharedPrefsStore() {
    _load();
  }

  ThemeMode _mode = ThemeMode.system;
  bool _useOledDark = true;
  Color? _seedColor;
  final KeyValueStore _store;

  ThemeMode get mode => _mode;
  bool get useOledDark => _useOledDark;
  Color get seedColor => _seedColor ?? AppColors.seed;
  bool get usesDefaultSeed => _seedColor == null;

  void setMode(ThemeMode mode, {bool? useOledDark}) {
    _mode = mode;
    if (useOledDark != null) {
      _useOledDark = useOledDark;
    }
    _persist();
    notifyListeners();
  }

  void setSeedColor(Color? color) {
    _seedColor = color;
    _persistSeed();
    notifyListeners();
  }

  Future<void> _load() async {
    final storedMode = await _store.getString(AppPrefsKeys.themeMode);
    final storedOled = await _store.getBool(AppPrefsKeys.themeOled);
    final storedSeed = await _store.getInt(AppPrefsKeys.themeSeed);
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
    if (storedSeed != null) {
      _seedColor = Color(storedSeed);
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await _store.setString(AppPrefsKeys.themeMode, _mode.name);
    await _store.setBool(AppPrefsKeys.themeOled, _useOledDark);
    await _persistSeed();
  }

  Future<void> _persistSeed() async {
    if (_seedColor == null) {
      await _store.remove(AppPrefsKeys.themeSeed);
      return;
    }
    await _store.setInt(AppPrefsKeys.themeSeed, _seedColor!.toARGB32());
  }
}
