import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_field_group.dart';

void main() {
  testWidgets('renders children with spacing', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DialogFieldGroup(
          spacing: 12,
          children: [Text('First'), Text('Second')],
        ),
      ),
    );

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 12,
      ),
      findsOneWidget,
    );
  });

  testWidgets('passes crossAxisAlignment to column', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DialogFieldGroup(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text('One')],
        ),
      ),
    );

    final column = tester.widget<Column>(find.byType(Column));
    expect(column.crossAxisAlignment, CrossAxisAlignment.center);
  });

  testWidgets('returns empty widget when no children', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DialogFieldGroup(children: []),
      ),
    );

    final widget = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(widget.width, 0);
    expect(widget.height, 0);
  });
}
