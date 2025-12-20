import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/safe_area_sheet.dart';

void main() {
  testWidgets('applies safe area + viewInsets padding', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(
          viewInsets: EdgeInsets.only(bottom: 24),
          padding: EdgeInsets.only(top: 8, bottom: 12, left: 4, right: 4),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SafeAreaSheet(
            padding: EdgeInsets.only(left: 10),
            child: SizedBox(height: 1),
          ),
        ),
      ),
    );

    final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
    expect(safeArea.top, isTrue);
    expect(safeArea.bottom, isTrue);
    expect(safeArea.left, isTrue);
    expect(safeArea.right, isTrue);

    final paddings = tester.widgetList<Padding>(find.byType(Padding)).toList();
    final hasOuter = paddings.any(
      (padding) => padding.padding == const EdgeInsets.only(left: 10),
    );
    final hasInsets = paddings.any(
      (padding) => padding.padding == const EdgeInsets.only(bottom: 24),
    );
    expect(hasOuter, isTrue);
    expect(hasInsets, isTrue);
  });

  testWidgets('can disable safe area edges', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SafeAreaSheet(
            safeAreaTop: false,
            safeAreaBottom: false,
            safeAreaSides: false,
            child: SizedBox(height: 1),
          ),
        ),
      ),
    );

    final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
    expect(safeArea.top, isFalse);
    expect(safeArea.bottom, isFalse);
    expect(safeArea.left, isFalse);
    expect(safeArea.right, isFalse);
  });
}
