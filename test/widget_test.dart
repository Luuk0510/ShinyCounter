import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/features/pokemon/data/repositories/prefs_pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_list_page.dart';

class _FakePokemonRepository extends PrefsPokemonRepository {
  @override
  Future<List<Pokemon>> loadCustomPokemon() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Shows empty state when no pokemon', (tester) async {
    final repo = _FakePokemonRepository();
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
        ],
        child: const MaterialApp(home: PokemonListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nog geen Pokémon toegevoegd'), findsOneWidget);
  });
}
