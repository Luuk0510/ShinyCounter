import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail/detail_header.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => child,
      ),
    ),
  );
}

void main() {
  testWidgets('tap toggles sprite when normal path exists', (tester) async {
    var toggled = false;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => DetailHeader(
            pokemon: const Pokemon(
              id: '0001',
              name: 'Bulbasaur',
              imagePath: 'assets/0001.png',
            ),
            shinyPath: 'assets/shiny.png',
            normalPath: 'assets/normal.png',
            showShiny: false,
            onToggleSprite: () => toggled = true,
            colors: Theme.of(context).colorScheme,
            isCaught: false,
            onToggleCaught: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    expect(toggled, isTrue);
  });

  testWidgets('tap is disabled when normal path is null', (tester) async {
    var toggled = false;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => DetailHeader(
            pokemon: const Pokemon(
              id: '0001',
              name: 'Bulbasaur',
              imagePath: 'assets/0001.png',
            ),
            shinyPath: 'assets/shiny.png',
            normalPath: null,
            showShiny: true,
            onToggleSprite: () => toggled = true,
            colors: Theme.of(context).colorScheme,
            isCaught: false,
            onToggleCaught: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    expect(toggled, isFalse);
  });
}
