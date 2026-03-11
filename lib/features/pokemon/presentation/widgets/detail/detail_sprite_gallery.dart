import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image_provider.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/shimmer_box.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';

class DetailSpriteGallery extends StatelessWidget {
  const DetailSpriteGallery({
    super.key,
    required this.colors,
    required this.pokemon,
    required this.spritePager,
    required this.currentSpriteIndex,
    required this.showNormal,
    required this.spritesLoading,
    required this.shinySprites,
    required this.normalMap,
    required this.spriteService,
    required this.onToggleVariant,
    required this.onPageChanged,
  });

  final ColorScheme colors;
  final Pokemon pokemon;
  final PageController spritePager;
  final int currentSpriteIndex;
  final bool showNormal;
  final bool spritesLoading;
  final List<String> shinySprites;
  final Map<String, String?> normalMap;
  final SpriteService spriteService;
  final VoidCallback onToggleVariant;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final sprites = <String>[pokemon.imagePath];
    if (shinySprites.isNotEmpty) {
      sprites
        ..clear()
        ..addAll(shinySprites);
    } else {
      final normal = _deriveNormalPath(pokemon.imagePath, pokemon.isLocalFile);
      if (normal != null && normal != pokemon.imagePath) {
        sprites.add(normal);
      }
    }
    final canSwipe = sprites.length > 1;

    final assetPaths = <String>[];
    for (final path in sprites) {
      if (pokemon.isLocalFile && !path.startsWith('assets/')) {
        precacheImage(pokemonImageProvider(path, isLocalFile: true), context);
      } else {
        assetPaths.add(path);
      }
      final normal = normalMap[path];
      if (normal != null) {
        if (pokemon.isLocalFile && !normal.startsWith('assets/')) {
          precacheImage(
            pokemonImageProvider(normal, isLocalFile: true),
            context,
          );
        } else {
          assetPaths.add(normal);
        }
      }
    }
    if (assetPaths.isNotEmpty) {
      unawaited(spriteService.precacheSpritePaths(context, assetPaths));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final shiny = sprites[currentSpriteIndex];
            final normal = normalMap[shiny];
            if (normal != null) {
              onToggleVariant();
            }
          },
          child: SizedBox(
            height: AppSizes.detailImageSize,
            child: spritesLoading
                ? const ShimmerBox(size: AppSizes.detailImageSize)
                : PageView.builder(
                    controller: spritePager,
                    allowImplicitScrolling: true,
                    itemCount: sprites.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      final shinyPath = sprites[index];
                      final normalPath = normalMap[shinyPath];
                      final selectedPath = showNormal && normalPath != null
                          ? normalPath
                          : shinyPath;
                      return Center(
                        child: AnimatedSwitcher(
                          duration: AppAnim.switcher,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: SizedBox(
                            key: ValueKey(selectedPath),
                            width: AppSizes.detailImageSize,
                            height: AppSizes.detailImageSize,
                            child: PokemonImage(
                              path: selectedPath,
                              isLocalFile: pokemon.isLocalFile,
                              borderRadius: 0,
                              fallbackIcon: Icons.catching_pokemon,
                              fallbackIconSize: AppSizes.detailImageFallback,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (canSwipe) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              sprites.length,
              (i) => AnimatedContainer(
                duration: AppAnim.switcher,
                curve: AppAnim.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                width: i == currentSpriteIndex
                    ? AppSizes.pageIndicatorDotActive
                    : AppSizes.pageIndicatorDot,
                height: i == currentSpriteIndex
                    ? AppSizes.pageIndicatorDotActive
                    : AppSizes.pageIndicatorDot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == currentSpriteIndex
                      ? AppButtonPalette.primaryFill(colors)
                      : AppButtonPalette.primaryFill(
                          colors,
                        ).withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String? _deriveNormalPath(String shinyPath, bool isLocalFile) {
    if (isLocalFile) return null;
    if (shinyPath.contains('_s.')) {
      return shinyPath.replaceFirst('_s.', '_n.');
    }
    if (shinyPath.contains('_r.')) {
      return shinyPath.replaceFirst('_r.', '_n.');
    }
    return null;
  }
}
