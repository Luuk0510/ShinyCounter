import 'dart:convert';

import 'package:shiny_counter/core/storage/app_prefs_keys.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';

class AppBackupService {
  AppBackupService({KeyValueStore? store})
    : _store = store ?? SharedPrefsStore();

  final KeyValueStore _store;

  Future<String> exportJson() async {
    final prefs = await _store.snapshot();
    final data = <String, Object?>{};
    for (final entry in prefs.entries) {
      if (!AppPrefsKeys.isManagedKey(entry.key)) continue;
      data[entry.key] = entry.value;
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
    final currentPrefs = await _store.snapshot();
    if (clearExisting) {
      for (final key in currentPrefs.keys.where(AppPrefsKeys.isManagedKey)) {
        await _store.remove(key);
      }
    }
    for (final entry in prefsData.entries) {
      final key = entry.key.toString();
      if (!AppPrefsKeys.isManagedKey(key)) continue;
      final value = entry.value;
      if (value is int) {
        await _store.setInt(key, value);
      } else if (value is bool) {
        await _store.setBool(key, value);
      } else if (value is String) {
        await _store.setString(key, value);
      }
    }
  }
}
