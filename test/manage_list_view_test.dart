import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/filters/search_gen_filter_row.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/list/manage_list_view.dart';
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
    home: Scaffold(body: child),
  );
}

void main() {
  const bulba = Pokemon(
    id: '0001',
    name: 'Bulbasaur',
    imagePath: 'assets/0001.png',
  );
  const pikachu = Pokemon(
    id: '0025',
    name: 'Pikachu',
    imagePath: 'assets/0025.png',
  );
  const wooper = Pokemon(
    id: '0194',
    name: 'Wooper',
    imagePath: 'assets/0194.png',
  );

  testWidgets('shows all items by default', (tester) async {
    await tester.pumpWidget(
      _wrap(ManageListView(pokemonSorted: const [bulba, pikachu, wooper])),
    );
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Wooper'), findsOneWidget);
  });

  testWidgets('filters by search query', (tester) async {
    await tester.pumpWidget(
      _wrap(ManageListView(pokemonSorted: const [bulba, pikachu, wooper])),
    );
    await tester.enterText(
      find.byKey(SearchGenFilterRow.searchFieldKey),
      'pika',
    );
    await tester.pumpAndSettle();
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);
    expect(find.text('Wooper'), findsNothing);
  });

  testWidgets('filters by generation', (tester) async {
    await tester.pumpWidget(
      _wrap(ManageListView(pokemonSorted: const [bulba, pikachu, wooper])),
    );
    await tester.tap(find.byKey(SearchGenFilterRow.genDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SearchGenFilterRow.genItemKey(2)));
    await tester.pumpAndSettle();
    expect(find.text('Wooper'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);
    expect(find.text('Pikachu'), findsNothing);
  });

  testWidgets('shows empty state when filters remove all items', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(ManageListView(pokemonSorted: const [bulba, pikachu, wooper])),
    );
    await tester.enterText(
      find.byKey(SearchGenFilterRow.searchFieldKey),
      'zapdos',
    );
    await tester.tap(find.byKey(SearchGenFilterRow.genDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SearchGenFilterRow.genItemKey(3)));
    await tester.pumpAndSettle();

    expect(find.text('No Pokémon found'), findsOneWidget);
    expect(
      find.text('Try another name, dex, or generation filter.'),
      findsOneWidget,
    );
    expect(find.text('Bulbasaur'), findsNothing);
    expect(find.text('Pikachu'), findsNothing);
    expect(find.text('Wooper'), findsNothing);
  });

  testWidgets('clear button resets search and list', (tester) async {
    await tester.pumpWidget(
      _wrap(ManageListView(pokemonSorted: const [bulba, pikachu, wooper])),
    );
    await tester.enterText(
      find.byKey(SearchGenFilterRow.searchFieldKey),
      'pika',
    );
    await tester.pumpAndSettle();
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);
    expect(find.text('Wooper'), findsNothing);

    await tester.tap(find.byKey(SearchGenFilterRow.clearButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Wooper'), findsOneWidget);
  });
}
