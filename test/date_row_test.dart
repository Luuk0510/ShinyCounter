import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail/date_row.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('shows placeholder when date is null', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DateRow(
          label: 'Start',
          value: null,
          onPick: () {},
          onClear: () {},
        ),
      ),
    );

    expect(find.text('--'), findsOneWidget);
  });

  testWidgets('taps call pick and clear handlers', (tester) async {
    var picked = 0;
    var cleared = 0;
    await tester.pumpWidget(
      _wrap(
        DateRow(
          label: 'Start',
          value: DateTime(2024, 1, 2),
          onPick: () => picked++,
          onClear: () => cleared++,
        ),
      ),
    );

    expect(find.text('02-01-2024'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.tap(find.byIcon(Icons.edit_calendar));
    await tester.tap(find.byIcon(Icons.clear));

    expect(picked, 2);
    expect(cleared, 1);
  });
}
