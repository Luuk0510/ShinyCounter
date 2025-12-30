import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppBackupService {
  AppBackupService({Future<SharedPreferences>? prefs})
    : _prefs = prefs ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefs;

  Future<String> exportJson() async {
    final prefs = await _prefs;
    final data = <String, Object?>{};
    for (final key in prefs.getKeys()) {
      data[key] = prefs.get(key);
    }
    final payload = <String, Object?>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'prefs': data,
    };
    return jsonEncode(payload);
  }

  Future<void> importJson(String raw, {bool clearExisting = true}) async {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Invalid backup format');
    }
    final prefsData = decoded['prefs'];
    if (prefsData is! Map) {
      throw const FormatException('Missing prefs data');
    }
    final prefs = await _prefs;
    if (clearExisting) {
      await prefs.clear();
    }
    for (final entry in prefsData.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List) {
        final list = value.whereType<String>().toList();
        await prefs.setStringList(key, list);
      }
    }
  }
}
