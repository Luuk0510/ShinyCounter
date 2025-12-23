import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/edit_pokemon_dialog.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

Widget _wrap() {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: SizedBox.shrink()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('save returns updated pokemon', (tester) async {
    await tester.pumpWidget(_wrap());

    const pokemon = Pokemon(
      id: '0001',
      name: 'Bulbasaur',
      imagePath: 'assets/0001.png',
    );

    final context = tester.element(find.byType(Scaffold));
    final future = showEditPokemonDialog(context, pokemon);
    await tester.pumpAndSettle();

    expect(find.text('Edit Pokémon'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Ivysaur');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isNotNull);
    expect(result!.id, pokemon.id);
    expect(result.name, 'Ivysaur');
    expect(result.imagePath, pokemon.imagePath);
    expect(result.isLocalFile, pokemon.isLocalFile);
  });

  testWidgets('cancel closes without result', (tester) async {
    await tester.pumpWidget(_wrap());

    const pokemon = Pokemon(
      id: '0001',
      name: 'Bulbasaur',
      imagePath: 'assets/0001.png',
    );

    final context = tester.element(find.byType(Scaffold));
    final future = showEditPokemonDialog(context, pokemon);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isNull);
  });
}
