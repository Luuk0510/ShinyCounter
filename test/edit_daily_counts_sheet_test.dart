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

Future<T?> _showSheet<T>(WidgetTester tester, Widget sheet) {
  final context = tester.element(find.byType(Scaffold));
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (_) => sheet,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('save returns edited daily counts', (tester) async {
    await tester.pumpWidget(_wrap());

    final future = _showSheet<Map<String, int>>(
      tester,
      EditDailyCountsSheet(
        dailyCounts: const {'2024-01-02': 3},
        dayFormatter: (value) => value,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isNotNull);
    expect(result!['2024-01-02'], 5);
  });

  testWidgets('cancel closes without result', (tester) async {
    await tester.pumpWidget(_wrap());

    final future = _showSheet<Map<String, int>>(
      tester,
      EditDailyCountsSheet(
        dailyCounts: const {'2024-01-02': 3},
        dayFormatter: (value) => value,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isNull);
  });
}
