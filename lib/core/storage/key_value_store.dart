import 'package:shared_preferences/shared_preferences.dart';

/// Small abstraction over SharedPreferences to allow swapping persistence.
abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
  Future<void> reload();
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
  Future<int?> getInt(String key) async {
    final p = await _prefs;
    return p.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    final p = await _prefs;
    await p.setInt(key, value);
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

  @override
  Future<void> remove(String key) async {
    final p = await _prefs;
    await p.remove(key);
  }

  @override
  Future<void> reload() async {
    final p = await _prefs;
    await p.reload();
  }
}
