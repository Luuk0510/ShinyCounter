import 'package:shiny_counter/core/storage/key_value_store.dart';

class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, Object?>? values])
    : _values = values ?? <String, Object?>{};

  final Map<String, Object?> _values;

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<void> setInt(String key, int value) async {
    _values[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<Map<String, Object?>> snapshot({bool reload = false}) async =>
      Map<String, Object?>.from(_values);

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> reload() async {}
}
