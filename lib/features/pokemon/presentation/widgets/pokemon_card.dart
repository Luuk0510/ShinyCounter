import 'package:flutter/material.dart';

import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/pokemon_image.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.isCaught,
    required this.onTap,
  });

  final Pokemon pokemon;
  final bool isCaught;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.cardPaddingH,
        vertical: AppSizes.cardPaddingV,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final imageSize = isCompact
              ? AppSizes.pokemonImageSmall
              : AppSizes.pokemonImageLarge;
          final fontSize = isCompact
              ? AppSizes.pokemonNameSmall
              : AppSizes.pokemonNameLarge;
          final horizontalGap = isCompact
              ? AppSizes.pokemonGapSmall
              : AppSizes.pokemonGapLarge;
          final contentPadding = isCompact
              ? AppSizes.pokemonContentSmall
              : AppSizes.pokemonContentLarge;
          final chevronSize = isCompact
              ? AppSizes.pokemonChevronSmall
              : AppSizes.pokemonChevronLarge;

          return Card(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(contentPadding),
                child: Row(
                  children: [
                    _buildImage(imageSize),
                    SizedBox(width: horizontalGap),
                    Expanded(
                      child: Text(
                        pokemon.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: chevronSize),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(double size) {
    return PokemonImage(
      path: pokemon.imagePath,
      isLocalFile: pokemon.isLocalFile,
      width: size,
      height: size,
      fallbackIconSize: size * 0.45,
    );
  }
}
