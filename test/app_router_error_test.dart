import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/routing/app_router.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';

import 'helpers/fakes.dart';

class _FakePokemonRepository implements PokemonRepository {
  @override
  Future<List<Pokemon>> loadCustomPokemon() async => const [];

  @override
  Future<Set<String>> loadCaught(List<Pokemon> allPokemon) async => {};

  @override
  Future<void> saveCustomPokemon(List<Pokemon> custom) async {}
}

void main() {
  testWidgets('pokemon detail route without extra shows error page', (
    tester,
  ) async {
    final repo = _FakePokemonRepository();
    final router = AppRouter.instance.router;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LoadCustomPokemonUseCase>(
            create: (_) => LoadCustomPokemonUseCase(repo),
          ),
          Provider<SaveCustomPokemonUseCase>(
            create: (_) => SaveCustomPokemonUseCase(repo),
          ),
          Provider<LoadCaughtUseCase>(
            create: (_) => LoadCaughtUseCase(repo),
          ),
          Provider<SpriteService>(
            create: (_) => FakeSpriteService(const []),
          ),
          Provider<CounterSync>(
            create: (_) => FakeCounterSync(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go(AppRoutes.pokemonDetail);
    await tester.pumpAndSettle();

    expect(find.text('Geen Pokémon meegegeven'), findsOneWidget);
  });
}
