import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/storage/app_prefs_keys.dart';

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

  test('loads stored locale and notifies', () async {
    final store = MemoryKeyValueStore({AppPrefsKeys.appLocale: 'nl'});

    final notifier = LocaleNotifier(store);
    await _waitForNotify(notifier);

    expect(notifier.locale?.languageCode, 'nl');
  });

  test('setLocale persists and notifies', () async {
    final store = MemoryKeyValueStore();
    final notifier = LocaleNotifier(store);
    await _waitForNotify(notifier);

    var count = 0;
    notifier.addListener(() => count++);

    await notifier.setLocale(const Locale('en'));
    expect(notifier.locale?.languageCode, 'en');
    expect(await store.getString(AppPrefsKeys.appLocale), 'en');
    expect(count, 1);
  });
}
