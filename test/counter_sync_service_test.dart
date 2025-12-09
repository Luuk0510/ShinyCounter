import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/storage/key_value_store.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/overlay/counter_overlay_message.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/counter_keys.dart';

class _MemoryStore implements KeyValueStore {
  final Map<String, String> strings = {};
  final Map<String, int> ints = {};
  final Map<String, bool> bools = {};
  int reloads = 0;

  void clear() {
    strings.clear();
    ints.clear();
    bools.clear();
  }

  @override
  Future<String?> getString(String key) async => strings[key];

  @override
  Future<void> setString(String key, String value) async {
    strings[key] = value;
  }

  @override
  Future<int?> getInt(String key) async => ints[key];

  @override
  Future<void> setInt(String key, int value) async {
    ints[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => bools[key];

  @override
  Future<void> setBool(String key, bool value) async {
    bools[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    strings.remove(key);
    ints.remove(key);
    bools.remove(key);
  }

  @override
  Future<void> reload() async {
    reloads++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const counterKey = 'counter_001';
  const caughtKey = 'caught_001';
  const message = CounterOverlayMessage(
    name: 'Bulbasaur',
    counterKey: counterKey,
    count: 5,
    enabled: true,
  );
  const channel = MethodChannel('x-slayer/overlay_channel');

  late _MemoryStore store;
  late CounterSyncService sync;
  late List<MethodCall> calls;
  late List<dynamic> shared;
  bool permGranted = true;
  bool requestGranted = true;
  bool isActive = false;
  bool showCalled = false;

  setUpAll(() async {
    store = _MemoryStore();
    sync = await CounterSyncService.instance(store: store);
  });

  setUp(() {
    store.clear();
    calls = [];
    shared = [];
    permGranted = true;
    requestGranted = true;
    isActive = false;
    showCalled = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'isPermissionGranted':
            case 'checkPermission':
              return permGranted;
            case 'requestPermission':
              return requestGranted;
            case 'isActive':
              return isActive;
            case 'showOverlay':
              showCalled = true;
              return true;
            case 'shareData':
              shared.add(call.arguments);
              return true;
            case 'closeOverlay':
              return true;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('setDailyCounts clears storage when empty', () async {
    final keys = CounterKeys.fromCounterKey(counterKey);
    store.strings[keys.dailyCounts] = '{"old":1}';

    await sync.setDailyCounts(counterKey, {});

    expect(store.strings.containsKey(keys.dailyCounts), isFalse);
  });

  test('setCaughtGame removes value when null or empty', () async {
    final keys = CounterKeys.fromCounterKey(counterKey);
    await sync.setCaughtGame(counterKey, 'violet');
    expect(store.strings[keys.caughtGame], 'violet');

    await sync.setCaughtGame(counterKey, '');
    expect(store.strings.containsKey(keys.caughtGame), isFalse);

    await sync.setCaughtGame(counterKey, 'scarlet');
    await sync.setCaughtGame(counterKey, null);
    expect(store.strings.containsKey(keys.caughtGame), isFalse);
  });

  test('loadState parses dates and drops zero daily counts', () async {
    final keys = CounterKeys.fromCounterKey(counterKey);
    store.ints[counterKey] = 3;
    store.bools[caughtKey] = true;
    store.strings[keys.startedAt] = DateTime(2024, 1, 1).toIso8601String();
    store.strings[keys.caughtAt] = DateTime(2024, 1, 2).toIso8601String();
    store.strings[keys.caughtGame] = 'violet';
    store.strings[keys.dailyCounts] = jsonEncode({
      'today': 2,
      'zero': 0,
      'text': '4',
    });

    final state = await sync.loadState(counterKey, caughtKey);

    expect(state.count, 3);
    expect(state.isCaught, isTrue);
    expect(state.startedAt, isNotNull);
    expect(state.caughtAt, isNotNull);
    expect(state.caughtGame, 'violet');
    expect(state.dailyCounts, {'today': 2, 'text': 4});
  });

  test('ensureOverlay returns false when permission denied', () async {
    permGranted = false;
    requestGranted = false;

    final result = await sync.ensureOverlay(message);

    expect(result, isFalse);
    expect(showCalled, isFalse);
    expect(shared, isEmpty);
  });

  test('ensureOverlay shares when overlay already active', () async {
    permGranted = true;
    isActive = true;

    final result = await sync.ensureOverlay(message);

    expect(result, isTrue);
    expect(showCalled, isFalse);
  });

  test('ensureOverlay shows and shares when overlay inactive', () async {
    permGranted = true;
    isActive = false;

    final result = await sync.ensureOverlay(message);

    expect(result, isTrue);
    expect(showCalled, isTrue);
  });
}
