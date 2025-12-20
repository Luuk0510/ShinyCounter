import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail/daily_counts_list.dart';
import 'package:shiny_counter/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(builder: (context) => child),
    ),
  );
}

void main() {
  testWidgets('renders sorted list and highlights counts', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => DailyCountsList(
            colors: Theme.of(context).colorScheme,
            dailyCounts: const {'2024-01-02': 5, '2024-01-03': 2},
            dayFormatter: (value) => value,
          ),
        ),
      ),
    );

    final first = find.text('2024-01-03');
    final second = find.text('2024-01-02');
    expect(first, findsOneWidget);
    expect(second, findsOneWidget);

    final firstOffset = tester.getTopLeft(first).dy;
    final secondOffset = tester.getTopLeft(second).dy;
    expect(firstOffset, lessThan(secondOffset));

    final context = tester.element(find.byType(DailyCountsList));
    final colors = Theme.of(context).colorScheme;
    final highlight = AppButtonPalette.primaryHighlight(colors);
    final countText = tester.widget<Text>(find.text('5'));
    expect(countText.style?.color, highlight);
  });
}
