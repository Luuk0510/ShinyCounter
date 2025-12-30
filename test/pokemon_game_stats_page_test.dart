import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_game_stats_page.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

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
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('empty stats page shows no counts message', (tester) async {
    const args = PokemonGameStatsArgs(game: 'SoulSilver', items: []);

    await tester.pumpWidget(_wrap(PokemonGameStatsPage(args: args)));

    expect(find.text('No counts yet'), findsOneWidget);
  });

  testWidgets('renders caught list items', (tester) async {
    final pokemon = Pokemon(
      id: '025',
      name: 'Pikachu',
      imagePath: 'missing_asset.png',
    );
    final items = [PokemonCaughtEntry(pokemon, DateTime(2024, 1, 2))];
    final args = PokemonGameStatsArgs(game: 'Yellow', items: items);

    await tester.pumpWidget(_wrap(PokemonGameStatsPage(args: args)));

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('02-01-2024'), findsOneWidget);
  });
}
