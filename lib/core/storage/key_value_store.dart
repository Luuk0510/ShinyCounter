import 'package:shared_preferences/shared_preferences.dart';

/// Small abstraction over SharedPreferences to allow swapping persistence.
abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore({Future<SharedPreferences>? prefs})
    : _prefs = prefs ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefs;

  @override
  Future<String?> getString(String key) async {
    final p = await _prefs;
    return p.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final p = await _prefs;
    await p.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final p = await _prefs;
    return p.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final p = await _prefs;
    await p.setBool(key, value);
  }
}
