import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/storage/app_prefs_keys.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/settings_sheet.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

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

Widget _wrap({
  required ThemeNotifier themeNotifier,
  required LocaleNotifier localeNotifier,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: themeNotifier),
      ChangeNotifierProvider.value(value: localeNotifier),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SizedBox.shrink()),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selecting theme/locale updates notifiers', (tester) async {
    final store = MemoryKeyValueStore({
      AppPrefsKeys.appLocale: 'en',
      AppPrefsKeys.themeMode: 'system',
      AppPrefsKeys.themeOled: true,
    });

    final themeNotifier = ThemeNotifier(store);
    final localeNotifier = LocaleNotifier(store);
    await Future.wait([
      _waitForNotify(themeNotifier),
      _waitForNotify(localeNotifier),
    ]);

    late BuildContext rootContext;
    await tester.pumpWidget(
      _wrap(themeNotifier: themeNotifier, localeNotifier: localeNotifier),
    );
    rootContext = tester.element(find.byType(Scaffold));

    showDialog<void>(
      context: rootContext,
      builder: (_) => const SettingsDialog(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dutch'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(localeNotifier.locale?.languageCode, 'nl');

    await tester.tap(find.text('Dark'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(themeNotifier.mode, ThemeMode.dark);
    expect(themeNotifier.useOledDark, isFalse);

    await tester.tap(find.text('OLED'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(themeNotifier.mode, ThemeMode.dark);
    expect(themeNotifier.useOledDark, isTrue);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsDialog), findsNothing);
  });
}
