import 'package:flutter/material.dart';

import 'pokemon.dart';
import 'pokemon_detail_page.dart';

const _pokemonList = <Pokemon>[
  Pokemon(name: 'Arceus', imagePath: 'assets/pokemon/arceus_shiny.png'),
  Pokemon(name: 'Darkrai', imagePath: 'assets/pokemon/darkrai_shiny.png'),
  Pokemon(name: 'Regigigas', imagePath: 'assets/pokemon/regigigas_shiny.png'),
];

class PokemonListPage extends StatelessWidget {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pokémon'),
      ),
      body: ListView.builder(
        itemCount: _pokemonList.length,
        itemBuilder: (context, index) {
          final pokemon = _pokemonList[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PokemonDetailPage(pokemon: pokemon),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          pokemon.imagePath,
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.catching_pokemon, size: 64),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          pokemon.name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
