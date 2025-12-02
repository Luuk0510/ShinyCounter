import 'package:flutter/material.dart';

class PokemonEmptyState extends StatelessWidget {
  const PokemonEmptyState({
    super.key,
    required this.onAddPressed,
    required this.imageAsset,
    required this.colors,
  });

  final VoidCallback onAddPressed;
  final String imageAsset;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imageAsset,
            width: 96,
            height: 96,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.catching_pokemon, size: 72),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nog geen Pokémon toegevoegd',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 180,
            child: ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text(
                'Voeg Pokémon toe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondary,
                foregroundColor: colors.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
