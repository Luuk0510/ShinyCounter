import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/selectable_row.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('SelectableRow shows selected background', (tester) async {
    const color = Colors.red;
    await tester.pumpWidget(
      _wrap(
        SelectableRow(
          selected: true,
          selectedColor: color,
          onTap: () {},
          child: Text('Row'),
        ),
      ),
    );

    final ink = tester.widget<Ink>(find.byType(Ink));
    final decoration = ink.decoration as BoxDecoration;
    expect(decoration.color, color.withValues(alpha: 0.08));
  });

  testWidgets('SelectableRow shows transparent background when unselected', (
    tester,
  ) async {
    const color = Colors.red;
    await tester.pumpWidget(
      _wrap(
        SelectableRow(
          selected: false,
          selectedColor: color,
          onTap: () {},
          child: Text('Row'),
        ),
      ),
    );

    final ink = tester.widget<Ink>(find.byType(Ink));
    final decoration = ink.decoration as BoxDecoration;
    expect(decoration.color, Colors.transparent);
  });

  testWidgets('SelectableCheckmark hides icon when unselected', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SelectableCheckmark(
          selected: false,
          selectedColor: Colors.blue,
          unselectedIcon: null,
        ),
      ),
    );

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('SelectableCheckmark animates when enabled', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SelectableCheckmark(
          selected: true,
          animate: true,
          selectedColor: Colors.blue,
        ),
      ),
    );

    expect(find.byType(AnimatedSize), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
  });
}
