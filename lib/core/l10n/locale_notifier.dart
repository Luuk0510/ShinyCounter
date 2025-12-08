import 'package:flutter/material.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';

class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier([KeyValueStore? store])
    : _store = store ?? SharedPrefsStore() {
    _load();
  }

  Locale? _locale;
  final KeyValueStore _store;
  Locale? get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final code = await _store.getString(_localeKey);
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
    await _store.setString(_localeKey, _locale?.languageCode ?? 'en');
  }

  static const _localeKey = 'app_locale';
}
