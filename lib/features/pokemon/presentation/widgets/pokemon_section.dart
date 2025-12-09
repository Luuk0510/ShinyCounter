import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/pokemon_card.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppTypography.sectionTitle)),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: AppAnim.normal,
                  curve: AppAnim.easeOut,
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: AppAnim.normal,
          curve: AppAnim.easeOut,
          alignment: Alignment.topCenter,
          child: ClipRect(
            child: expanded
                ? Column(
                    children: [
                      for (final p in pokemons)
                        PokemonCard(
                          key: ValueKey(p.id),
                          pokemon: p,
                          isCaught: isCaught(p),
                          onTap: () => onTap(p),
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
