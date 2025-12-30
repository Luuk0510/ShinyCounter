import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

void main() {
  testWidgets('L10nX extension resolves localizations', (tester) async {
    late BuildContext rootContext;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(rootContext.l10n.statsTitle, 'Statistics');
  });
}
