import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/pokemon_sheets.dart';

void main() {
  testWidgets('shows bottom sheet content and uses barrier opacity', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                showPokemonBottomSheet<void>(
                  context,
                  barrierOpacity: 0.5,
                  builder: (_) => const Text('Sheet Body'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet Body'), findsOneWidget);

    final barrier = tester.widget<AnimatedModalBarrier>(
      find.byType(AnimatedModalBarrier),
    );
    final color = barrier.color.value;
    expect(color, isNotNull);
    expect(color!.a, moreOrLessEquals(0.5, epsilon: 0.01));
  });
}
