import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/manage_list_view.dart';
import 'package:shiny_counter/l10n/gen/app_localizations_en.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizationsEn.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  final bulba = const Pokemon(id: '0001', name: 'Bulbasaur', imagePath: 'assets/0001.png');
  final pikachu = const Pokemon(id: '0025', name: 'Pikachu', imagePath: 'assets/0025.png');
  final wooper = const Pokemon(id: '0194', name: 'Wooper', imagePath: 'assets/0194.png');

  testWidgets('shows all items by default', (tester) async {
    await tester.pumpWidget(_wrap(ManageListView(pokemonSorted: [bulba, pikachu, wooper])));
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Wooper'), findsOneWidget);
  });

  testWidgets('filters by search query', (tester) async {
    await tester.pumpWidget(_wrap(ManageListView(pokemonSorted: [bulba, pikachu, wooper])));
    await tester.enterText(find.byType(TextField).first, 'pika');
    await tester.pumpAndSettle();
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);
    expect(find.text('Wooper'), findsNothing);
  });

  testWidgets('filters by generation', (tester) async {
    await tester.pumpWidget(_wrap(ManageListView(pokemonSorted: [bulba, pikachu, wooper])));
    // Open dropdown
    await tester.tap(find.byType(DropdownButtonFormField<int?>));
    await tester.pumpAndSettle();
    // Select Gen 2 (Wooper only)
    await tester.tap(find.text('Gen 2').last);
    await tester.pumpAndSettle();
    expect(find.text('Wooper'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);
    expect(find.text('Pikachu'), findsNothing);
  });
}
