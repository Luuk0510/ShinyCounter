import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/features/pokemon/data/repositories/prefs_pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_list_page.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/pokemon_card.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class _SeededRepo extends PrefsPokemonRepository {
  final List<Pokemon> seed;
  _SeededRepo(this.seed);

  @override
  Future<List<Pokemon>> loadCustomPokemon() async => seed;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('manage sheet can delete a pokemon', (tester) async {
    final repo = _SeededRepo([
      const Pokemon(
        id: 'p-pika',
        name: 'Pikachu',
        imagePath: 'assets/icon/pokeball_icon.png',
      ),
      const Pokemon(
        id: 'p-eevee',
        name: 'Eevee',
        imagePath: 'assets/icon/pokeball_icon.png',
      ),
    ]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LoadCustomPokemonUseCase>(
            create: (_) => LoadCustomPokemonUseCase(repo),
          ),
          Provider<SaveCustomPokemonUseCase>(
            create: (_) => SaveCustomPokemonUseCase(repo),
          ),
          Provider<LoadCaughtUseCase>(create: (_) => LoadCaughtUseCase(repo)),
          Provider<SpriteService>.value(value: SpriteRepository()),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('en'), Locale('nl')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PokemonListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(PokemonCard), findsNWidgets(2));

    // Open manage sheet.
    await tester.tap(find.byTooltip('Manage Pokémon'));
    await tester.pumpAndSettle();

    // Tap delete icon for Pikachu.
    final listTile = find.ancestor(
      of: find.text('Pikachu'),
      matching: find.byType(ListTile),
    );
    final deleteButton = find.descendant(
      of: listTile,
      matching: find.byIcon(Icons.delete_outline),
    );
    await tester.tap(deleteButton.first);
    await tester.pumpAndSettle();

    // Confirm delete dialog.
    final deleteAction = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(ElevatedButton, 'Delete'),
    );
    await tester.tap(deleteAction);
    await tester.pumpAndSettle();

    expect(find.byType(PokemonCard), findsNWidgets(1));
    expect(find.text('Pikachu'), findsNothing);
  });
}
