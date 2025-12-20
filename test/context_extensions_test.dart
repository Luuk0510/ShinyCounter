import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shiny_counter/core/routing/app_router.dart';
import 'package:shiny_counter/core/routing/context_extensions.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

void main() {
  testWidgets('goToPokemon pushes detail route with extra', (tester) async {
    const pokemon = Pokemon(
      id: '0001',
      name: 'Bulbasaur',
      imagePath: 'assets/0001.png',
    );

    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) {
            return Scaffold(
              body: TextButton(
                onPressed: () => context.goToPokemon(pokemon),
                child: const Text('Go'),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.pokemonDetail,
          builder: (context, state) {
            final extra = state.extra as Pokemon;
            return Scaffold(body: Text(extra.name));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsOneWidget);
  });
}
