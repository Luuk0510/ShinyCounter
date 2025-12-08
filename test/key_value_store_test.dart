import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';

class _MemoryStore implements KeyValueStore {
  final Map<String, String> _strings = {};
  final Map<String, int> _ints = {};
  final Map<String, bool> _bools = {};

  @override
  Future<bool?> getBool(String key) async => _bools[key];

  @override
  Future<int?> getInt(String key) async => _ints[key];

  @override
  Future<String?> getString(String key) async => _strings[key];

  @override
  Future<void> reload() async {}

  @override
  Future<void> remove(String key) async {
    _strings.remove(key);
    _ints.remove(key);
    _bools.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _bools[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _ints[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _strings[key] = value;
  }
}

void main() {
  test('in-memory KeyValueStore round trips values and removes them', () async {
    final store = _MemoryStore();
    await store.setString('s', 'hello');
    await store.setInt('i', 42);
    await store.setBool('b', true);

    expect(await store.getString('s'), 'hello');
    expect(await store.getInt('i'), 42);
    expect(await store.getBool('b'), true);

    await store.remove('s');
    expect(await store.getString('s'), isNull);
  });
}
