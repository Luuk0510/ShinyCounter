import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.pokemon,
    required this.shinyPath,
    required this.normalPath,
    required this.showShiny,
    required this.onToggleSprite,
    required this.colors,
    required this.isCaught,
    required this.onToggleCaught,
  });

  final Pokemon pokemon;
  final String shinyPath;
  final String? normalPath;
  final bool showShiny;
  final VoidCallback onToggleSprite;
  final ColorScheme colors;
  final bool isCaught;
  final VoidCallback onToggleCaught;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: GestureDetector(
            onTap: normalPath == null ? null : onToggleSprite,
            child: AnimatedSwitcher(
              duration: AppAnim.switcher,
              child: pokemon.isLocalFile && !kIsWeb
                  ? Image.file(
                      File(pokemon.imagePath),
                      key: ValueKey(showShiny),
                      width: AppSizes.detailImageSize,
                      height: AppSizes.detailImageSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => const Icon(
                        Icons.catching_pokemon,
                        size: AppSizes.detailImageFallback,
                      ),
                    )
                  : Image.asset(
                      showShiny || normalPath == null ? shinyPath : normalPath!,
                      key: ValueKey(showShiny),
                      width: AppSizes.detailImageSize,
                      height: AppSizes.detailImageSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => const Icon(
                        Icons.catching_pokemon,
                        size: AppSizes.detailImageFallback,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.none),
      ],
    );
  }
}
