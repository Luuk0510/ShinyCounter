import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/storage/app_prefs_keys.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';

import 'helpers/memory_store.dart';

Future<void> _waitForNotify(ChangeNotifier notifier) {
  final completer = Completer<void>();
  void listener() {
    if (!completer.isCompleted) completer.complete();
    notifier.removeListener(listener);
  }

  notifier.addListener(listener);
  return completer.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads stored theme mode and oled flag', () async {
    final store = MemoryKeyValueStore({
      AppPrefsKeys.themeMode: 'dark',
      AppPrefsKeys.themeOled: false,
    });

    final notifier = ThemeNotifier(store);
    await _waitForNotify(notifier);

    expect(notifier.mode, ThemeMode.dark);
    expect(notifier.useOledDark, isFalse);
  });

  test('setMode persists and notifies', () async {
    final store = MemoryKeyValueStore();
    final notifier = ThemeNotifier(store);
    await _waitForNotify(notifier);

    var count = 0;
    notifier.addListener(() => count++);

    notifier.setMode(ThemeMode.light, useOledDark: false);
    expect(notifier.mode, ThemeMode.light);
    expect(notifier.useOledDark, isFalse);
    expect(await store.getString(AppPrefsKeys.themeMode), 'light');
    expect(await store.getBool(AppPrefsKeys.themeOled), isFalse);
    expect(count, 1);
  });
}
