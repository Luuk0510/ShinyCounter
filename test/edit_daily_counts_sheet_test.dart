import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/bottom_sheets/edit_daily_counts_sheet.dart';
import 'package:shiny_counter/l10n/app_localizations.dart';

Widget _wrap() {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: SizedBox.shrink()),
  );
}

Future<T?> _pushSheet<T>(WidgetTester tester, Widget sheet) {
  final context = tester.element(find.byType(Scaffold));
  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => Scaffold(body: sheet),
    ),
  );
}

Future<void> _pumpSheet(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppLocalizations l10n(WidgetTester tester) {
    final context = tester.element(find.byType(EditDailyCountsSheet));
    return AppLocalizations.of(context)!;
  }

  MaterialLocalizations material(WidgetTester tester) {
    final context = tester.element(find.byType(EditDailyCountsSheet));
    return MaterialLocalizations.of(context);
  }

  testWidgets('save returns edited daily counts', (tester) async {
    await tester.pumpWidget(_wrap());

    final future = _pushSheet<Map<String, int>>(
      tester,
      EditDailyCountsSheet(
        dailyCounts: const {'2024-01-02': 3},
        dayFormatter: (value) => value,
      ),
    );
    await _pumpSheet(tester);
    expect(find.byType(EditDailyCountsSheet), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '5');
    await tester.tap(find.text('Save'));
    await _pumpSheet(tester);

    final result = await future;
    expect(result, isNotNull);
    expect(result!['2024-01-02'], 5);
  });

  testWidgets('cancel closes without result', (tester) async {
    await tester.pumpWidget(_wrap());

    final future = _pushSheet<Map<String, int>>(
      tester,
      EditDailyCountsSheet(
        dailyCounts: const {'2024-01-02': 3},
        dayFormatter: (value) => value,
      ),
    );
    await _pumpSheet(tester);
    expect(find.byType(EditDailyCountsSheet), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await _pumpSheet(tester);

    final result = await future;
    expect(result, isNull);
  });

  testWidgets('add row flow adds a new row', (tester) async {
    await tester.pumpWidget(_wrap());

    final future = _pushSheet<Map<String, int>>(
      tester,
      EditDailyCountsSheet(
        dailyCounts: const {'2024-01-02': 3},
        dayFormatter: (value) => value,
      ),
    );
    await _pumpSheet(tester);
    expect(find.byType(EditDailyCountsSheet), findsOneWidget);

    final initialDeleteCount =
        tester.widgetList(find.byIcon(Icons.delete_outline)).length;

    await tester.tap(find.text(l10n(tester).addCountRow));
    await _pumpSheet(tester);

    await tester.tap(find.text(material(tester).okButtonLabel));
    await _pumpSheet(tester);

    final dialogField = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(dialogField, '7');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(l10n(tester).save),
      ),
    );
    await _pumpSheet(tester);

    expect(
      find.byIcon(Icons.delete_outline),
      findsNWidgets(initialDeleteCount + 1),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, l10n(tester).save));
    await _pumpSheet(tester);

    final result = await future;
    expect(result, isNotNull);
    expect(result!.values, contains(7));
  });

}
