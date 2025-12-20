import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_entry.dart';

void main() {
  testWidgets('DialogEntry builds with child', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DialogEntry(child: Text('Content')),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
    expect(find.byType(Transform), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsOneWidget);
  });

  testWidgets('DialogEntry reverse flag still renders', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DialogEntry(reverse: true, child: Text('Reverse')),
      ),
    );

    expect(find.text('Reverse'), findsOneWidget);
  });
}
