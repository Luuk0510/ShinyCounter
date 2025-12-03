import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.pokemon,
    required this.colors,
    required this.isCaught,
    required this.onToggleCaught,
  });

  final Pokemon pokemon;
  final ColorScheme colors;
  final bool isCaught;
  final VoidCallback onToggleCaught;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: pokemon.isLocalFile && !kIsWeb
              ? Image.file(
                  File(pokemon.imagePath),
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.catching_pokemon, size: 140),
                )
              : Image.asset(
                  pokemon.imagePath,
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.catching_pokemon, size: 140),
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: 150,
          child: ElevatedButton(
            onPressed: onToggleCaught,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCaught
                  ? Colors.green.shade600
                  : colors.secondary,
              foregroundColor: isCaught ? Colors.white : colors.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                isCaught ? l10n.buttonCaught : l10n.buttonCatch,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
