import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier() {
    _load();
  }

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    } else {
      // Default to system language on first run (if supported).
      final platform = WidgetsBinding.instance.platformDispatcher.locale;
      if (platform.languageCode == 'nl') {
        _locale = const Locale('nl');
      } else {
        _locale = const Locale('en');
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _locale?.languageCode ?? 'en');
  }

  static const _localeKey = 'app_locale';
}
