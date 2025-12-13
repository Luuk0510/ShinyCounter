import 'package:flutter/material.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/list/collapsible_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/list/pokemon_card.dart';

class PokemonSection extends StatelessWidget {
  const PokemonSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.pokemons,
    required this.isCaught,
    required this.onTap,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Pokemon> pokemons;
  final bool Function(Pokemon) isCaught;
  final Future<void> Function(Pokemon) onTap;

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: title,
      expanded: expanded,
      onToggle: onToggle,
      child: Column(
        key: ValueKey('section_$title'),
        children: [
          for (final p in pokemons)
            PokemonCard(
              key: ValueKey(p.id),
              pokemon: p,
              isCaught: isCaught(p),
              onTap: () => onTap(p),
            ),
        ],
      ),
    );
  }
}
