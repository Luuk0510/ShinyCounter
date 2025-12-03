import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final imageSize = isCompact ? 110.0 : 150.0;
          final fontSize = isCompact ? 24.0 : 37.0;
          final horizontalGap = isCompact ? 12.0 : 16.0;
          final contentPadding = isCompact ? 12.0 : 14.0;
          final chevronSize = isCompact ? 24.0 : 28.0;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
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
    final image = pokemon.isLocalFile && !kIsWeb
        ? Image.file(
            File(pokemon.imagePath),
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.catching_pokemon, size: size * 0.45),
          )
        : Image.asset(
            pokemon.imagePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.catching_pokemon, size: size * 0.45),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image,
    );
  }
}
