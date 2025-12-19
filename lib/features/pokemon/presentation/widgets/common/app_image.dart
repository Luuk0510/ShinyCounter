import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

typedef AppImageFallbackBuilder =
    Widget Function(BuildContext context, double? size);

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = AppRadii.sm,
    this.fallbackIcon = Icons.catching_pokemon,
    this.fallbackIconSize,
    this.fallbackBuilder,
  });

  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final double? fallbackIconSize;
  final AppImageFallbackBuilder? fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, _, _) {
        final size = fallbackIconSize ?? width ?? height;
        if (fallbackBuilder != null) {
          return fallbackBuilder!(context, size);
        }
        return Icon(fallbackIcon, size: size);
      },
    );

    if (borderRadius <= 0) return imageWidget;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageWidget,
    );
  }
}
