import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/pokemon_image_provider.dart';

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
    final image = Image(
      image: pokemonImageProvider(path, isLocalFile: isLocalFile),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, _, __) {
        final size = fallbackIconSize ?? (width ?? height);
        return Icon(fallbackIcon, size: size);
      },
    );

    if (borderRadius <= 0) return image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}

