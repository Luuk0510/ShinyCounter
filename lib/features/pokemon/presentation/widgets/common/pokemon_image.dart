import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/app_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image_provider.dart';

class PokemonImage extends StatelessWidget {
  const PokemonImage({
    super.key,
    required this.path,
    required this.isLocalFile,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = AppRadii.sm,
    this.fallbackIcon = Icons.catching_pokemon,
    this.fallbackIconSize,
  });

  final String path;
  final bool isLocalFile;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final double? fallbackIconSize;

  @override
  Widget build(BuildContext context) {
    return AppImage(
      image: pokemonImageProvider(path, isLocalFile: isLocalFile),
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      fallbackIcon: fallbackIcon,
      fallbackIconSize: fallbackIconSize,
    );
  }
}
