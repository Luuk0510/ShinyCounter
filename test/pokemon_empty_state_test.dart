import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_empty_state.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Builder(builder: (context) => child)),
  );
}

void main() {
  testWidgets('renders title and action, taps call handler', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => PokemonEmptyState(
            onAddPressed: () => tapped = true,
            imageAsset: 'assets/does_not_exist.png',
            colors: Theme.of(context).colorScheme,
            title: 'No Pokémon',
            actionLabel: 'Add',
          ),
        ),
      ),
    );

    expect(find.text('No Pokémon'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    expect(tapped, isTrue);
  });
}
